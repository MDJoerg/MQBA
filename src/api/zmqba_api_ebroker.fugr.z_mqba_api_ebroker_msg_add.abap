FUNCTION Z_MQBA_API_EBROKER_MSG_ADD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_BROKER) TYPE  STRING
*"     VALUE(IV_TOPIC) TYPE  STRING
*"     VALUE(IV_PAYLOAD) TYPE  STRING
*"     VALUE(IV_MSG_ID) TYPE  STRING OPTIONAL
*"     VALUE(IT_PROPS) TYPE  ZMQBA_MSG_T_PRP OPTIONAL
*"  EXPORTING
*"     VALUE(EV_ERROR_TEXT) TYPE  ZMQBA_ERROR_TEXT
*"     VALUE(EV_ERROR) TYPE  ZMQBA_FLAG_ERROR
*"     VALUE(EV_GUID) TYPE  ZMQBA_MSG_GUID
*"     VALUE(EV_SCOPE) TYPE  ZMQBA_MSG_SCOPE
*"--------------------------------------------------------------------

* init
  ev_error      = abap_true.
  ev_error_text = 'unknown error'.

* create a message
  DATA(lr_msg) = zcl_mqba_factory=>create_message( ).

* fill main data
  lr_msg->set_topic( iv_topic ).
  lr_msg->set_payload( iv_payload ).
  lr_msg->set_sender( iv_broker ).
  lr_msg->set_id( iv_msg_id ).
  lr_msg->set_scope( zif_mqba_broker=>c_scope_external ).

* fill props
  IF it_props[] IS NOT INITIAL.
    LOOP AT it_props ASSIGNING FIELD-SYMBOL(<ls_prop>).
      lr_msg->set_property(
        EXPORTING
          iv_name  = <ls_prop>-name
          iv_value = <ls_prop>-value
      ).
    ENDLOOP.
  ENDIF.

* get broker
  DATA(lr_broker) = zcl_mqba_factory=>get_broker( ).
  IF lr_broker->external_message_arrived( lr_msg ) EQ abap_true.
    ev_guid = lr_msg->zif_mqba_request~get_guid( ).
    CLEAR: ev_error_text,
           ev_error.
  ELSE.
    ev_error_text = lr_broker->get_last_error( ).
  ENDIF.

ENDFUNCTION.
