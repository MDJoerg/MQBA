FUNCTION z_mqba_api_ebroker_msgs_add.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_BROKER) TYPE  STRING
*"     VALUE(IT_MSG) TYPE  ZMQBA_API_T_EBR_MSG
*"     VALUE(IV_NO_QUEUE) TYPE  BAPI_FLAG DEFAULT SPACE
*"  EXPORTING
*"     VALUE(EV_ERROR) TYPE  ZMQBA_FLAG_ERROR
*"     VALUE(ES_RESULT) TYPE  ZMQBA_API_S_EBR_MSG_OUT
*"----------------------------------------------------------------------

* ------ local data
  DATA: ls_params TYPE zmqba_api_s_ebr_msg_in.

* init
  ev_error          = abap_false.
  IF iv_broker IS INITIAL
    OR it_msg[] IS INITIAL.
    RETURN.
  ENDIF.

* ------ prepare params
  ls_params-broker          = iv_broker.
  ls_params-msgs            = it_msg.
  ls_params-flag_no_queue   = iv_no_queue.


* ------ get broker and call api (background processing possible)
  DATA(lr_broker) = zcl_mqba_factory=>get_broker( ).
  es_result = lr_broker->external_messages_arrived( ls_params ).
  ev_error  = es_result-error_flag.

ENDFUNCTION.
