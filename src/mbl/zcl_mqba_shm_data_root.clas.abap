class ZCL_MQBA_SHM_DATA_ROOT definition
  public
  inheriting from ZCL_MQBA_SHM_BL_MEMORY
  create public
  shared memory enabled .

public section.

  interfaces IF_SHM_BUILD_INSTANCE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MQBA_SHM_DATA_ROOT IMPLEMENTATION.


  METHOD if_shm_build_instance~build.

* local data
    DATA: lr_root TYPE REF TO zcl_mqba_shm_data_root.
    DATA: lx_exc  TYPE REF TO cx_root.

    TRY.

*      get handle for
        DATA(lr_area) = zcl_mqba_shm_area=>attach_for_write( inst_name   = cl_shm_area=>default_instance ).

*      create new data instance
        CREATE OBJECT lr_root AREA HANDLE lr_area.

*      init internal references with area handle
*        DATA: lr_gwibl TYPE REF TO zcl_mqba_cfg_topic_filter.
*        CREATE OBJECT lr_gwibl AREA HANDLE lr_area
*          EXPORTING
*            iv_base_tab = 'ZTC_MQBAGIBL'.
*        lr_root->mr_gwi_blacklist = lr_gwibl.
*
*        DATA: lr_gwiwl TYPE REF TO zcl_mqba_cfg_topic_filter.
*        CREATE OBJECT lr_gwibl AREA HANDLE lr_area
*          EXPORTING
*            iv_base_tab = 'ZTC_MQBAGIWL'.
*        lr_root->mr_gwi_whitelist = lr_gwibl.

*        CREATE OBJECT lr_root->mr_gwi_blacklist
*            EXPORTING = NEW zcl_mqba_cfg_topic_filter( 'ZTC_MQBAGIBL' ) area handle l_area.
*        lr_root->mr_gwi_whitelist = NEW zcl_mqba_cfg_topic_filter( 'ZTC_MQBAGIWL' ) area handle l_area.
*
*      initial load
*        lr_root->initialize( ).

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
          SUBKEY 'build_shma_failed'
          FIELDS lv_error.
        MESSAGE lv_error TYPE 'E'.
    ENDTRY.

    IF invocation_mode = cl_shm_area=>invocation_mode_auto_build.
      CALL FUNCTION 'DB_COMMIT'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
