*&---------------------------------------------------------------------*
*& Report ZMQBA_GUI_PUBLISH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmqba_gui_publish.

PARAMETERS: p_topic     TYPE zmqba_topic_publish OBLIGATORY.
PARAMETERS: p_payld     TYPE zmqba_value_text OBLIGATORY.
PARAMETERS: p_consid    TYPE zmqba_consumer_id.
PARAMETERS: p_ext       TYPE zmqba_flag_external AS CHECKBOX.
PARAMETERS: p_broker    TYPE zmqba_broker_id.

START-OF-SELECTION.

* ------- local data
  DATA: lv_error TYPE abap_bool.
  DATA: lv_error_text TYPE string.
  DATA: lv_guid TYPE zmqba_msg_guid.
  DATA: lv_scope TYPE zmqba_msg_scope.



* ------- publish via api
  CALL FUNCTION 'Z_MQBA_API_BROKER_PUBLISH'
    EXPORTING
      iv_topic      = CONV string( p_topic )
      iv_payload    = CONV string( p_payld )
      iv_session_id = p_consid
      iv_external   = p_ext
      iv_gateway    = p_broker
*     IV_CONTEXT    =
*     IT_PROPS      =
    IMPORTING
      ev_error_text = lv_error_text
      ev_error      = lv_error
      ev_guid       = lv_guid
      ev_scope      = lv_scope.

* -------- output error as message
  IF lv_error EQ abap_true.
    MESSAGE e006(zmqba) WITH p_topic p_payld lv_error_text.
  ELSE.
    MESSAGE s007(zmqba) WITH lv_guid lv_scope.
  ENDIF.
