FUNCTION z_mqba_api_broker_publish.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_TOPIC) TYPE  STRING
*"     VALUE(IV_PAYLOAD) TYPE  STRING
*"     VALUE(IV_SESSION_ID) TYPE  STRING OPTIONAL
*"     VALUE(IV_EXTERNAL) TYPE  BAPI_FLAG OPTIONAL
*"     VALUE(IV_CONTEXT) TYPE  STRING OPTIONAL
*"     VALUE(IT_PROPS) TYPE  ZMQBA_MSG_T_PRP OPTIONAL
*"  EXPORTING
*"     VALUE(EV_ERROR_TEXT) TYPE  ZMQBA_ERROR_TEXT
*"     VALUE(EV_ERROR) TYPE  ZMQBA_FLAG_ERROR
*"     VALUE(EV_GUID) TYPE  ZMQBA_MSG_GUID
*"     VALUE(EV_SCOPE) TYPE  ZMQBA_MSG_SCOPE
*"----------------------------------------------------------------------

* ------- publish via mqba api
* get a message producer
  DATA(lr_producer) = zcl_mqba_factory=>get_producer( ).
* set the main fields
  lr_producer->set_topic( iv_topic )->set_payload( iv_payload )->set_consumer_id( iv_session_id ).
* set context
  IF iv_context IS NOT INITIAL.
    lr_producer->set_context( iv_context ).
  ENDIF.
* distribute to external broker?
  IF iv_external = abap_true.
    lr_producer->set_external( ).
  ENDIF.
* set additional fields
  IF it_props[] IS NOT INITIAL.
    LOOP AT it_props ASSIGNING FIELD-SYMBOL(<lfs_prop>).
      lr_producer->set_field( iv_name = <lfs_prop>-name iv_value = <lfs_prop>-name ).
    ENDLOOP.
  ENDIF.
* publish now
  IF lr_producer->publish( ) EQ abap_false.
* errors occured
    ev_error = abap_true.
    ev_error_text = lr_producer->get_error_text( ).
  ELSE.
* success !
    DATA(lr_msg) = lr_producer->get_message( ).
    ev_error = abap_false.
    ev_guid  = lr_msg->get_guid( ).
    ev_scope = lr_msg->get_scope( ).
  ENDIF.

ENDFUNCTION.
