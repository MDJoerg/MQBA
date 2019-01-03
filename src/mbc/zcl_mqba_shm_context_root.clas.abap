class ZCL_MQBA_SHM_CONTEXT_ROOT definition
  public
  create public
  shared memory enabled .

public section.

  interfaces IF_SHM_BUILD_INSTANCE .
  interfaces ZIF_MQBA_SHM_CONTEXT .
protected section.

  data MT_CACHE type ZMQBA_MBC_T_DATA .
  data MV_GROUP type STRING .

  methods GET_GROUP
    importing
      !IV_GROUP type DATA
    returning
      value(RV_GROUP) type ZMQBA_PARAM_GROUP .
private section.
ENDCLASS.



CLASS ZCL_MQBA_SHM_CONTEXT_ROOT IMPLEMENTATION.


  METHOD get_group.
    rv_group = COND #( WHEN iv_group IS NOT INITIAL
                       THEN iv_group
                       ELSE mv_group ).
  ENDMETHOD.


  METHOD if_shm_build_instance~build.
* local data
    DATA: lr_root TYPE REF TO zcl_mqba_shm_context_root.
    DATA: lx_exc  TYPE REF TO cx_root.

    TRY.

*      get handle for
        DATA(lr_area) = zcl_mqba_shm_context_area=>attach_for_write( inst_name   = cl_shm_area=>default_instance ).

*      create new data instance
        CREATE OBJECT lr_root AREA HANDLE lr_area.

*      set root and detach
        lr_area->set_root( lr_root ).
        lr_area->detach_commit( ).

      CATCH cx_shm_exclusive_lock_active
            cx_shm_version_limit_exceeded
            cx_shm_change_lock_active
            cx_shm_parameter_error
            cx_shm_pending_lock_removed
            INTO lx_exc.
        DATA(lv_error) = lx_exc->get_text( ).
        LOG-POINT ID zmqba_shm
          SUBKEY 'build_shma_context_failed'
          FIELDS lv_error.
        MESSAGE lv_error TYPE 'E'.
    ENDTRY.

    IF invocation_mode = cl_shm_area=>invocation_mode_auto_build.
      CALL FUNCTION 'DB_COMMIT'.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_shm_context~calc_int.
    DATA(lv_group) = get_group( iv_group ).

    READ TABLE mt_cache ASSIGNING FIELD-SYMBOL(<lfs_row>)
      WITH KEY param_group = lv_group
               param_name  = iv_param.
    IF sy-subrc EQ 0
      AND <lfs_row> IS ASSIGNED.
      rv_int = <lfs_row>-param_value.
      ADD iv_delta TO rv_int.
      <lfs_row>-param_value = rv_int.
    ELSE.
      DATA: ls_row LIKE LINE OF mt_cache.
      ls_row-param_group = lv_group.
      ls_row-param_name  = iv_param.
      ls_row-param_value = iv_delta.
      INSERT ls_row INTO TABLE mt_cache.
      rv_int = iv_delta.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_shm_context~clear.
    DATA(lv_group) = get_group( iv_group ).
    DESCRIBE TABLE mt_cache LINES DATA(lv_old).

    DELETE mt_cache WHERE param_group = lv_group.
    DESCRIBE TABLE mt_cache LINES DATA(lv_new).

    rv_success = COND #( WHEN lv_old = lv_new
                         THEN abap_false
                         ELSE abap_true ).
  ENDMETHOD.


  METHOD zif_mqba_shm_context~get.

    DATA(lv_group) = get_group( iv_group ).

    READ TABLE mt_cache ASSIGNING FIELD-SYMBOL(<lfs_row>)
      WITH KEY param_group = lv_group
               param_name  = iv_param.
    IF sy-subrc EQ 0
      AND <lfs_row> IS ASSIGNED.
      rv_value = <lfs_row>-param_value.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_shm_context~get_count.
    DATA(lv_group) = get_group( iv_group ).

    LOOP AT mt_cache TRANSPORTING NO FIELDS
      WHERE param_group EQ lv_group.
      ADD 1 TO rv_count.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_mqba_shm_context~get_groups.
    LOOP AT mt_cache ASSIGNING FIELD-SYMBOL(<lfs_cache>).
      READ TABLE rt_groups TRANSPORTING NO FIELDS
        WITH KEY table_line = <lfs_cache>-param_group.
      IF sy-subrc NE 0.
        APPEND INITIAL LINE TO rt_groups ASSIGNING FIELD-SYMBOL(<lfs_out>).
        <lfs_out> = <lfs_cache>-param_group.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_mqba_shm_context~get_names.
    DATA(lv_group) = get_group( iv_group ).
    LOOP AT mt_cache ASSIGNING FIELD-SYMBOL(<lfs_row>)
      WHERE param_group EQ lv_group.
      APPEND INITIAL LINE TO rt_names ASSIGNING FIELD-SYMBOL(<lfs_name>).
      <lfs_name> = <lfs_row>-param_name.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_mqba_shm_context~get_tab.

    DATA: ls_out LIKE LINE OF rt_param.
    DATA(lv_group) = get_group( iv_group ).

    LOOP AT mt_cache ASSIGNING FIELD-SYMBOL(<lfs_cache>)
      WHERE param_group = lv_group.

      IF it_param[] IS NOT INITIAL.
        READ TABLE it_param TRANSPORTING NO FIELDS
          WITH KEY table_line = <lfs_cache>-param_name.
        IF sy-subrc NE 0.
          CONTINUE.
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING <lfs_cache> TO ls_out.
      INSERT ls_out INTO TABLE rt_param.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_mqba_shm_context~put.

    DATA(lv_group) = get_group( iv_group ).

    READ TABLE mt_cache ASSIGNING FIELD-SYMBOL(<lfs_row>)
      WITH KEY param_group = lv_group
               param_name  = iv_param.
    IF sy-subrc EQ 0
      AND <lfs_row> IS ASSIGNED.
      <lfs_row>-param_value = iv_value.
    ELSE.
      DATA ls_row LIKE LINE OF mt_cache.
      ls_row-param_group = lv_group.
      ls_row-param_name  = iv_param.
      ls_row-param_value = iv_value.
      INSERT ls_row INTO TABLE mt_cache.
    ENDIF.

    rv_success = abap_true.

  ENDMETHOD.


  METHOD zif_mqba_shm_context~put_tab.

    DATA(lv_group) = get_group( iv_group ).
    rv_success = abap_true.

    LOOP AT it_param ASSIGNING FIELD-SYMBOL(<lfs_row>).
      IF zif_mqba_shm_context~put(
        iv_group = lv_group
        iv_param = <lfs_row>-param_name
        iv_value = <lfs_row>-param_value ) EQ abap_false.

        rv_success = abap_false.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_mqba_shm_context~remove.
    DATA ls_row LIKE LINE OF mt_cache.
    DATA(lv_group) = get_group( iv_group ).

    ls_row-param_group = lv_group.
    ls_row-param_name  = iv_param.

    DELETE TABLE mt_cache FROM ls_row.

    rv_success = COND #( WHEN sy-subrc = 0
                         THEN abap_true
                         ELSE abap_false ).
  ENDMETHOD.


  METHOD zif_mqba_shm_context~set_group.
    mv_group = iv_group.
    rr_self = me.
  ENDMETHOD.
ENDCLASS.
