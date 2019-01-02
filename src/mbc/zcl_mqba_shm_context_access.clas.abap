class ZCL_MQBA_SHM_CONTEXT_ACCESS definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_SHM_CONTEXT .
protected section.

  data MR_AREA type ref to ZCL_MQBA_SHM_CONTEXT_AREA .
  data MV_BIND_UPDATE type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MX_EXCEPTION type ref to CX_ROOT .
  data MV_BIND_RETRY type I value 1000 ##NO_TEXT.
  data MV_GROUP type STRING .

  methods BIND_READ
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods BIND_UPDATE
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods GET_GROUP
    importing
      !IV_GROUP type DATA
    returning
      value(RV_GROUP) type ZMQBA_PARAM_GROUP .
  methods RELEASE
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
private section.
ENDCLASS.



CLASS ZCL_MQBA_SHM_CONTEXT_ACCESS IMPLEMENTATION.


  METHOD bind_read.

* -------- init
    rv_success = abap_false.
    IF mr_area IS NOT INITIAL.
      release( ).
    ENDIF.

* -------- get area access
* ---- try to store the current message to shared memory
    DO mv_bind_retry TIMES.
      TRY.
*   store new event to shared memory
*       reset m_exception
          CLEAR mx_exception.
*       get area access
          mr_area = zcl_mqba_shm_context_area=>attach_for_read( ).
*       exit from do
          IF mr_area IS NOT INITIAL.
            rv_success = abap_true.
            mv_bind_update = abap_false.
            EXIT.
          ENDIF.
*       catch errors
        CATCH cx_shm_inconsistent
              cx_shm_no_active_version
              cx_shm_exclusive_lock_active
              cx_shm_version_limit_exceeded
              cx_shm_change_lock_active
              cx_shm_parameter_error
              cx_shm_pending_lock_removed
              INTO mx_exception.
      ENDTRY.
    ENDDO.

  ENDMETHOD.


  METHOD bind_update.

* -------- init
    rv_success = abap_false.
    IF mr_area IS NOT INITIAL.
      release( ).
    ENDIF.

* -------- get area access
* ---- try to store the current message to shared memory
    DO mv_bind_retry TIMES.
      TRY.
*   store new event to shared memory
*       reset m_exception
          CLEAR mx_exception.
*       get area access
          mr_area = zcl_mqba_shm_context_area=>attach_for_update( ).
*       exit from do
          IF mr_area IS NOT INITIAL.
            rv_success = abap_true.
            mv_bind_update = abap_true.
            EXIT.
          ENDIF.
*       catch errors
        CATCH cx_shm_inconsistent
              cx_shm_no_active_version
              cx_shm_exclusive_lock_active
              cx_shm_version_limit_exceeded
              cx_shm_change_lock_active
              cx_shm_parameter_error
              cx_shm_pending_lock_removed
              INTO mx_exception.
      ENDTRY.
    ENDDO.

  ENDMETHOD.


  METHOD GET_GROUP.
    rv_group = COND #( WHEN iv_group IS NOT INITIAL
                       THEN iv_group
                       ELSE mv_group ).
  ENDMETHOD.


  METHOD release.

* -------- init
    CLEAR mx_exception.
    IF mr_area IS INITIAL.
      rv_success = abap_true.
      RETURN.
    ELSE.
      rv_success = abap_false.
    ENDIF.

    rv_success = abap_false.


* --------- release
    DO mv_bind_retry TIMES.
      TRY.
*   store new event to shared memory
*       release access
          IF mv_bind_update EQ abap_true.
            mr_area->detach_commit( ).
          ELSE.
            mr_area->detach( ).
          ENDIF.
*       sucess?
          rv_success = abap_true.
          CLEAR mr_area.
          EXIT.
*       catch errors
        CATCH cx_shm_inconsistent
              cx_shm_no_active_version
              cx_shm_exclusive_lock_active
              cx_shm_version_limit_exceeded
              cx_shm_change_lock_active
              cx_shm_parameter_error
              cx_shm_pending_lock_removed
              INTO mx_exception.
      ENDTRY.
    ENDDO.

  ENDMETHOD.


  METHOD zif_mqba_shm_context~clear.
    IF bind_update( ) EQ abap_false.
      RETURN.
    ELSE.
      DATA(lv_group) = get_group( iv_group ).
      rv_success = mr_area->root->zif_mqba_shm_context~clear( lv_group ).
      release( ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_mqba_shm_context~get.

    IF bind_read( ) EQ abap_false.
      RETURN.
    ELSE.
      DATA(lv_group) = get_group( iv_group ).

      rv_value = mr_area->root->zif_mqba_shm_context~get(
          iv_group = lv_group
          iv_param = iv_param
      ).

      release( ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_mqba_shm_context~get_count.
    IF bind_read( ) EQ abap_false.
      RETURN.
    ELSE.
      DATA(lv_group) = get_group( iv_group ).
      rv_count = mr_area->root->zif_mqba_shm_context~get_count( lv_group ).
      release( ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_mqba_shm_context~get_names.
    IF bind_read( ) EQ abap_false.
      RETURN.
    ELSE.
      DATA(lv_group) = get_group( iv_group ).
      rt_names = mr_area->root->zif_mqba_shm_context~get_names( lv_group ).
      release( ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_mqba_shm_context~put.

    IF bind_update( ) EQ abap_false.
      rv_success = abap_false.
    ELSE.
      DATA(lv_group) = get_group( iv_group ).

      rv_success = mr_area->root->zif_mqba_shm_context~put(
          iv_group = lv_group
          iv_param = iv_param
          iv_value = iv_value
      ).

      release( ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_shm_context~set_group.
    mv_group = iv_group.
    rr_self = me.
  ENDMETHOD.
ENDCLASS.
