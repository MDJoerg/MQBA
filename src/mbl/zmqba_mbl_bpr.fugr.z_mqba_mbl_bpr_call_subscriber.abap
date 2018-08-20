FUNCTION z_mqba_mbl_bpr_call_subscriber.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_CONTEXT) TYPE  ZMQBA_API_S_BPR_SUB_CALL
*"  EXCEPTIONS
*"      ERRORS_OCCURED
*"      WRONG_CONFIG
*"      UNKNOWN_RESULT
*"      MESSAGE_TYPE_X
*"----------------------------------------------------------------------

* ----- local data
  DATA: lr_subscriber TYPE REF TO zif_mqba_subscriber.
  DATA: lv_class      TYPE seoclsname.


* ----- prepare subscriber module
  lv_class = is_context-sub_cfg-sub_module.
  IF lv_class IS INITIAL.
    lv_class = is_context-sub_act_cfg-sub_module.
  ENDIF.
  IF lv_class IS INITIAL.
    RAISE wrong_config.
  ENDIF.

* ----- prepare qrfc
  DATA(lr_qrfc) = zcl_mqba_factory=>create_util_qrfc( ).


* ----- create class and process
  CREATE OBJECT lr_subscriber TYPE (lv_class).
  DATA(lv_result) = lr_subscriber->process( is_context ).


* ----- process result
  CASE lv_result.
    WHEN 'I' OR 'S' OR ' '.
      " success, do nithing
    WHEN 'W'.
      " process warning as log point
      LOG-POINT ID zmqba_int
         SUBKEY 'subscriber_process_qrfc_warning'
         FIELDS lv_class
                is_context.
    WHEN 'E'.
      IF lr_qrfc->set_status_retry_later( ) EQ abap_false.
        RAISE errors_occured.
      ENDIF.
    WHEN 'A'.
      RAISE errors_occured.
    WHEN 'X'.
      RAISE message_type_x.
    WHEN OTHERS.
      RAISE unknown_result.
  ENDCASE.



ENDFUNCTION.
