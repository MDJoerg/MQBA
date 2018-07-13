class ZCL_MQBA_MESSAGE definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_REQUEST .

  methods SET_DATA_FROM_IF
    importing
      !IR_MSG type ref to ZIF_MQBA_REQUEST
      !IV_NEW_GUID type ABAP_BOOL default ABAP_TRUE
    returning
      value(RR_SELF) type ref to ZCL_MQBA_MESSAGE .
  methods SET_PROPERTY
    importing
      !IV_NAME type DATA
      !IV_VALUE type DATA .
  methods SET_MSG_CONTEXT
    importing
      !IR_CONTEXT type ref to ZIF_MQBA_CONTEXT .
  methods SET_MSG_RESPONSE
    importing
      !IR_RESPONSE type ref to ZIF_MQBA_RESPONSE .
  methods SET_MAIN_DATA
    importing
      !IV_TOPIC type DATA
      !IV_PAYLOAD type DATA
      !IV_SCOPE type ZMQBA_MSG_SCOPE default 'I'
      !IV_ID type DATA optional
      !IV_CONTEXT type DATA optional
      !IV_SENDER type DATA optional
    returning
      value(RR_SELF) type ref to ZCL_MQBA_MESSAGE .
  methods SET_TOPIC
    importing
      !IV_TOPIC type DATA
    returning
      value(RR_SELF) type ref to ZCL_MQBA_MESSAGE .
  methods SET_PAYLOAD
    importing
      !IV_PAYLOAD type DATA
    returning
      value(RR_SELF) type ref to ZCL_MQBA_MESSAGE .
  methods SET_SCOPE
    importing
      !IV_SCOPE type ZMQBA_MSG_SCOPE
    returning
      value(RR_SELF) type ref to ZCL_MQBA_MESSAGE .
  methods SET_SENDER
    importing
      !IV_SENDER type DATA
    returning
      value(RR_SELF) type ref to ZCL_MQBA_MESSAGE .
  methods SET_CONTEXT
    importing
      !IV_CONTEXT type DATA
    returning
      value(RR_SELF) type ref to ZCL_MQBA_MESSAGE .
  methods SET_ID
    importing
      !IV_ID type DATA
    returning
      value(RR_SELF) type ref to ZCL_MQBA_MESSAGE .
  class-methods CREATE
    importing
      !IV_CLASS type SEOCLSNAME default 'ZCL_MQBA_MESSAGE'
    returning
      value(RR_INSTANCE) type ref to ZCL_MQBA_MESSAGE .
  methods CONSTRUCTOR .
protected section.

  data M_TOPIC type STRING .
  data M_PAYLOAD type STRING .
  data M_ID type STRING .
  data M_CONTEXT type STRING .
  data M_SENDER type STRING .
  data M_MSG_CONTEXT type ref to ZIF_MQBA_CONTEXT .
  data M_MSG_RESPONSE type ref to ZIF_MQBA_RESPONSE .
  data M_TIMESTAMP type ZMQBA_TIMESTAMP .
  data M_GUID type ZMQBA_MSG_GUID .
  data M_PROPS type ZMQBA_MSG_T_PRP .
  data M_SCOPE type ZMQBA_MSG_SCOPE .

  methods TO_BOOLEAN
    importing
      !IV_IN type DATA
    returning
      value(RV_OUT) type ABAP_BOOL .
  methods TO_STRING
    importing
      !IV_IN type DATA
    returning
      value(RV_OUT) type STRING .
  methods TO_INT
    importing
      !IV_IN type DATA
    returning
      value(RV_OUT) type I .
private section.
ENDCLASS.



CLASS ZCL_MQBA_MESSAGE IMPLEMENTATION.


  METHOD constructor.
* set default valus
    GET TIME STAMP FIELD m_timestamp.

    m_guid = zcl_mqba_factory=>create_msg_guid( ).

    m_sender = |{ sy-sysid }CLNT{ sy-mandt }/{ sy-cprog }|.
    m_id     = |{ sy-uname }/{ sy-modno }/{ sy-datum }/{ sy-uzeit }|.

  ENDMETHOD.


  METHOD create.
    CREATE OBJECT rr_instance TYPE (iv_class).
  ENDMETHOD.


  METHOD set_context.
*   fill data
    m_context  = iv_context.

*   fill return
    rr_self = me.
  ENDMETHOD.


  METHOD set_data_from_if.

* check
    CHECK ir_msg IS NOT INITIAL.

* get guid
    IF iv_new_guid EQ abap_true.
      m_guid = zcl_mqba_factory=>create_msg_guid( ).
    ELSE.
      m_guid = ir_msg->get_guid( ).
    ENDIF.


* get normal fields
    m_topic     = ir_msg->get_topic( ).
    m_payload   = ir_msg->get_payload( ).
    m_context   = ir_msg->get_context( ).
    m_sender    = ir_msg->get_sender( ).
    m_id        = ir_msg->get_id( ).
    m_timestamp = ir_msg->get_timestamp( ).
    m_scope     = ir_msg->get_scope( ).

* get properties
    LOOP AT ir_msg->get_properties( )
      ASSIGNING FIELD-SYMBOL(<lfs_name>).
      APPEND INITIAL LINE
        TO m_props ASSIGNING FIELD-SYMBOL(<lfs_line>).

      <lfs_line>-name = <lfs_name>.
      <lfs_line>-value = ir_msg->get_property( <lfs_name> ).
    ENDLOOP.

* get references
    m_msg_context   = ir_msg->get_msg_context( ).
    m_msg_response  = ir_msg->get_msg_response( ).


* finally set myself
    rr_self = me.

  ENDMETHOD.


  METHOD set_id.
*   fill data
    m_id       = iv_id.

*   fill return
    rr_self = me.
  ENDMETHOD.


  METHOD set_main_data.
*   fill main data
    m_topic    = iv_topic.
    m_payload  = iv_payload.
    m_id       = iv_id.
    m_context  = iv_context.
    m_sender   = iv_sender.
    m_scope    = iv_scope.

*   fill return
    rr_self = me.
  ENDMETHOD.


  METHOD set_msg_context.
    m_msg_context = ir_context.
  ENDMETHOD.


  METHOD set_msg_response.
  ENDMETHOD.


  METHOD set_payload.
*   fill data
    m_payload  = iv_payload.

*   fill return
    rr_self = me.
  ENDMETHOD.


  METHOD set_property.

*  local data
    FIELD-SYMBOLS: <lfs_line> LIKE LINE OF m_props.

*  check existing
    READ TABLE m_props ASSIGNING <lfs_line>
      WITH KEY name = iv_name.
    IF <lfs_line> IS ASSIGNED.
*  check to delete
      IF iv_value IS INITIAL.
        UNASSIGN <lfs_line>.
        DELETE m_props WHERE name = iv_name.
      ELSE.
        <lfs_line>-value = iv_value.
      ENDIF.
    ELSE.
*    append if not empty
      IF iv_value IS NOT INITIAL.
        APPEND INITIAL LINE TO m_props ASSIGNING <lfs_line>.
        <lfs_line>-name = iv_name.
        <lfs_line>-value = iv_value.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD set_scope.
*   fill data
    m_scope    = iv_scope.

*   fill return
    rr_self = me.
  ENDMETHOD.


  METHOD set_sender.
*   fill data
    m_sender   = iv_sender.

*   fill return
    rr_self = me.
  ENDMETHOD.


  METHOD set_topic.
*   fill data
    m_topic    = iv_topic.

*   fill return
    rr_self = me.
  ENDMETHOD.


  METHOD to_boolean.

* set default to false
    rv_out = abap_false.

* check for some typical data for "true"
    IF   iv_in = '1'
      OR iv_in = 'true'
      OR iv_in = 't'
      OR iv_in = 'on'.
      rv_out = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD to_int.
    rv_out = CONV integer( iv_in ).
  ENDMETHOD.


  METHOD to_string.

    rv_out = CONV string( iv_in ).

  ENDMETHOD.


  METHOD zif_mqba_request~get_context.
    rv_context = m_context.
  ENDMETHOD.


  METHOD zif_mqba_request~get_context_obj.
  ENDMETHOD.


  METHOD zif_mqba_request~get_guid.
    rv_guid = m_guid.
  ENDMETHOD.


  METHOD zif_mqba_request~get_id.
    rv_id = m_id.
  ENDMETHOD.


  METHOD zif_mqba_request~get_msg_context.
    rr_context = m_msg_context.
  ENDMETHOD.


  METHOD zif_mqba_request~get_msg_response.
    rr_response = m_msg_response.
  ENDMETHOD.


  METHOD zif_mqba_request~get_payload.
    rv_payload = m_payload.
  ENDMETHOD.


  METHOD zif_mqba_request~get_properties.

    CHECK m_props[] IS NOT INITIAL.
    LOOP AT m_props ASSIGNING FIELD-SYMBOL(<lfs_line>).
      APPEND INITIAL LINE TO rt_prp_names ASSIGNING FIELD-SYMBOL(<lfs_name>).
      <lfs_name> = <lfs_line>-name.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_mqba_request~get_property.
    READ TABLE m_props ASSIGNING FIELD-SYMBOL(<lfs_line>) WITH KEY name = iv_name.
    IF <lfs_line> IS ASSIGNED.
      rv_value = <lfs_line>-value.
    ENDIF.
  ENDMETHOD.


  METHOD zif_mqba_request~get_response.
    rr_response = m_msg_response.
  ENDMETHOD.


  METHOD zif_mqba_request~get_scope.
    rv_scope = m_scope.
  ENDMETHOD.


  METHOD zif_mqba_request~get_sender.
    rv_sender = m_sender.
  ENDMETHOD.


  METHOD zif_mqba_request~get_timestamp.
    rv_timestamp = m_timestamp.
  ENDMETHOD.


  METHOD zif_mqba_request~get_topic.
    rv_topic = m_topic.
  ENDMETHOD.


  METHOD zif_mqba_request~is_valid.
    rv_valid = COND #( WHEN m_topic IS NOT INITIAL AND m_payload IS NOT INITIAL
                       THEN abap_true
                       ELSE abap_false ).
  ENDMETHOD.
ENDCLASS.
