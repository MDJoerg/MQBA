FUNCTION z_mqba_api_broker_get_session.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(EV_ERROR) TYPE  ZMQBA_FLAG_ERROR
*"     VALUE(EV_ERROR_TEXT) TYPE  ZMQBA_ERROR_TEXT
*"     VALUE(EV_CONSUMER_ID) TYPE  STRING
*"----------------------------------------------------------------------


*   init
  ev_error = abap_false.
*   create consumer
  DATA(lr_consumer) = zcl_mqba_factory=>get_consumer( ).
*   get my id
  ev_consumer_id = lr_consumer->get_consumer_id( ).
*   error handling
  IF ev_consumer_id IS INITIAL.
    ev_error = abap_true.
    MESSAGE i005(zmqba) INTO ev_error_text. "no sessiom id
  ENDIF.


ENDFUNCTION.
