FUNCTION z_mqba_api_ebroker_msgs_add.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_BROKER) TYPE  STRING
*"     VALUE(IT_MSG) TYPE  ZMQBA_API_T_EBR_MSG
*"  EXPORTING
*"     VALUE(EV_ERROR) TYPE  ZMQBA_FLAG_ERROR
*"----------------------------------------------------------------------

* init
  ev_error      = abap_false.

* loop
  LOOP AT it_msg INTO DATA(ls_msg).
    CALL FUNCTION 'Z_MQBA_API_EBROKER_MSG_ADD'
      EXPORTING
        iv_broker  = iv_broker
        iv_topic   = ls_msg-topic
        iv_payload = ls_msg-payload
        iv_msg_id  = CONV string( ls_msg-msg_id )
*       IT_PROPS   =
      IMPORTING
*       EV_ERROR_TEXT       =
        ev_error   = ev_error
*       EV_GUID    =
*       EV_SCOPE   =
      .
    CHECK ev_error EQ abap_false.
  ENDLOOP.

ENDFUNCTION.
