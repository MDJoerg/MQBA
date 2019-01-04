FUNCTION z_mqba_api_ebroker_publish.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_BROKER_ID) TYPE  ZMQBA_BROKER_ID
*"     VALUE(IV_TOPIC) TYPE  STRING
*"     VALUE(IV_PAYLOAD) TYPE  STRING
*"  EXPORTING
*"     VALUE(EV_ERROR_TEXT) TYPE  ZMQBA_ERROR_TEXT
*"     VALUE(EV_ERROR) TYPE  ZMQBA_FLAG_ERROR
*"----------------------------------------------------------------------

* ---------- init
  ev_error = abap_true.
  ev_error_text = |unknown error|.


* ---------- get broker
  DATA(lr_broker) = zcl_mqba_factory=>get_broker( ).
  IF lr_broker IS INITIAL.
    RETURN.
  ENDIF.


* ---------- call broker
  DATA(lv_success) = lr_broker->external_message_publish(
      iv_topic     = iv_topic
      iv_payload   = iv_payload
      iv_broker_id = iv_broker_id
  ).

* ---------- error handling
  IF lv_success EQ abap_true.
    CLEAR: ev_error, ev_error_text.
  ELSE.
    ev_error_text = lr_broker->get_last_error( ).
  ENDIF.




ENDFUNCTION.
