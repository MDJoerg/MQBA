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


* ---------- get an instance
  DATA(lr_ebroker) = zcl_mqba_factory=>get_broker_proxy( iv_broker_id ).
  IF lr_ebroker IS INITIAL.
    ev_error_text = |unknown broker { iv_broker_id }|.
    RETURN.
  ENDIF.


* ----------- connect
  IF lr_ebroker->connect( ) EQ abap_false.
    ev_error_text = |connection failed to { iv_broker_id }|.
    RETURN.
  ENDIF.


* ----------- publish
  IF lr_ebroker->publish(
       iv_topic   = iv_topic
       iv_payload = iv_payload
     ) EQ abap_false.
    ev_error_text = |publish failed to { iv_broker_id }|.
  ELSE.
    CLEAR ev_error.
    CLEAR ev_error_text.
  ENDIF.


* ------------ destoy
  lr_ebroker->destroy( ).

ENDFUNCTION.
