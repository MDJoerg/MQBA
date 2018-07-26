FUNCTION z_mqba_api_broker_subscribe.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_TOPIC) TYPE  STRING OPTIONAL
*"     VALUE(IT_TOPIC) TYPE  ZMQBA_T_STRING OPTIONAL
*"     VALUE(IV_CONTEXT) TYPE  STRING OPTIONAL
*"     VALUE(IV_WAIT_FOR_SEC) TYPE  I DEFAULT 5
*"  EXPORTING
*"     VALUE(EV_ERROR) TYPE  ZMQBA_FLAG_ERROR
*"     VALUE(EV_ERROR_TEXT) TYPE  ZMQBA_ERROR_TEXT
*"     VALUE(ET_PROPS) TYPE  ZMQBA_MSG_T_PRP
*"     VALUE(EV_PAYLOAD) TYPE  STRING
*"     VALUE(EV_TOPIC) TYPE  STRING
*"     VALUE(EV_CONSUMER_ID) TYPE  STRING
*"----------------------------------------------------------------------


* ------- call mqba consumer api
* check topic
  IF iv_topic IS INITIAL
  AND it_topic IS INITIAL.
    ev_error = abap_true.
    MESSAGE i003(zqmba) INTO ev_error_text.
  ELSE.


*   create consumer
    DATA(lr_consumer) = zcl_mqba_factory=>get_consumer( ).
*   get my id
    ev_consumer_id = lr_consumer->get_consumer_id( ).


*   subscribe to topics
    IF iv_topic IS NOT INITIAL.
      lr_consumer->subscribe( iv_topic ).
    ELSE.
      LOOP AT it_topic INTO DATA(lv_topic).
        lr_consumer->subscribe( lv_topic ).
      ENDLOOP.
    ENDIF.

*   filter context
    IF iv_context IS NOT INITIAL.
      lr_consumer->set_context_filter( iv_context ).
    ENDIF.

*   wait now
    IF lr_consumer->wait_for_messages( iv_wait_for_sec ) EQ abap_true.
* -----   output success
      TRY.
*   get pcp data
          DATA(lr_pcp) = lr_consumer->get_message_pcp( ).
          DATA(lr_msg) = lr_consumer->get_message( ).

          ev_payload = lr_msg->get_payload( ).
          ev_topic   = lr_msg->get_topic( ).

          lr_pcp->get_fields( CHANGING c_fields = et_props ).

*   set success
          ev_error = abap_false.
*   errors
        CATCH cx_ac_message_type_pcp_error INTO DATA(pcp_exc).
          ev_error = abap_true.
          ev_error_text = pcp_exc->get_text( ).
      ENDTRY.
    ELSE.
* ------ output error
      ev_error = abap_true.
      MESSAGE i004(zmqba) INTO ev_error_text. "timeout
    ENDIF.
  ENDIF.

ENDFUNCTION.
