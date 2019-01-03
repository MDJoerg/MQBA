FUNCTION z_mqba_api_ebroker_queue_proc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_BROKER) TYPE  STRING
*"     VALUE(IT_MSG) TYPE  ZMQBA_API_T_EBR_MSG
*"  EXPORTING
*"     VALUE(EV_ERROR) TYPE  ZMQBA_FLAG_ERROR
*"     VALUE(ES_RESULT) TYPE  ZMQBA_API_S_EBR_MSG_OUT
*"----------------------------------------------------------------------

* ------- call standard routine without queuing
  CALL FUNCTION 'Z_MQBA_API_EBROKER_MSGS_ADD'
    EXPORTING
      iv_broker   = iv_broker
      it_msg      = it_msg
      iv_no_queue = 'X'
    IMPORTING
      ev_error    = ev_error
      es_result   = es_result.

* -------- check errors in queue
  IF ev_error = abap_true.
    DATA(lr_qrfc) = zcl_mqba_factory=>create_util_qrfc( ).
    lr_qrfc->set_status_retry_later( ).
  ENDIF.

ENDFUNCTION.
