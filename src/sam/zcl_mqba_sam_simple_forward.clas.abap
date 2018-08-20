class ZCL_MQBA_SAM_SIMPLE_FORWARD definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_SUBSCRIBER .
protected section.

  constants C_PARAM1_USAGE type STRING value '/my/Forwared/Message/Topic' ##NO_TEXT.
  constants C_PARAM2_USAGE type STRING value 'X' ##NO_TEXT.
private section.
ENDCLASS.



CLASS ZCL_MQBA_SAM_SIMPLE_FORWARD IMPLEMENTATION.


  METHOD ZIF_MQBA_SUBSCRIBER~PROCESS.

* ------ local data and macros
    DATA: lv_error_text TYPE  zmqba_error_text.
    DATA: lv_error      TYPE zmqba_flag_error.
    DATA: lv_guid       TYPE  zmqba_msg_guid.
    DATA: lv_scope TYPE  zmqba_msg_scope.

    DEFINE get_config.
      DATA(&1) = CONV &2( is_context-sub_act_cfg-&3 ).
      IF is_context-sub_cfg-&3 IS NOT INITIAL.
        &1 = is_context-sub_cfg-&3.
      ENDIF.
    END-OF-DEFINITION.


* ------ init
    rv_msg_type = 'X'.


* ------ get the new topic from param 1
    get_config lv_topic string param1.
    IF lv_topic IS INITIAL.
      rv_msg_type = 'A'.  " wrong config, no restart
      RETURN.
    ENDIF.


* ------ get the payload
    DATA(lv_payload) = CONV string( is_context-msg-payload ).
    IF lv_payload IS INITIAL.
      rv_msg_type = 'W'.  " no payload -> no forward
      RETURN.
    ENDIF.


* ------ get external flag
    get_config lv_external abap_bool param2.


* ------ call publish api
    CALL FUNCTION 'Z_MQBA_API_BROKER_PUBLISH'
      EXPORTING
        iv_topic      = lv_topic
        iv_payload    = lv_payload
*       IV_SESSION_ID =
        iv_external   = lv_external
*       IV_CONTEXT    =
*       IT_PROPS      =
      IMPORTING
        ev_error_text = lv_error_text
        ev_error      = lv_error
        ev_guid       = lv_guid
        ev_scope      = lv_scope.



* ----- fill output
    IF lv_error EQ abap_false.
      rv_msg_type = 'S'.  " success
    ELSE.
      rv_msg_type = 'E'.  " retry should be possible
    ENDIF.

  ENDMETHOD.
ENDCLASS.
