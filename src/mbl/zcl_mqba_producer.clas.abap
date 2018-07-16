class ZCL_MQBA_PRODUCER definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_PRODUCER .

  methods CONSTRUCTOR .
protected section.

  data M_CONSUMER_ID type STRING .
  data M_EXTERNAL type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data M_EXCEPTION type ref to CX_ROOT .
  data M_MSG type ref to ZCL_MQBA_INT_MESSAGE .
private section.
ENDCLASS.



CLASS ZCL_MQBA_PRODUCER IMPLEMENTATION.


  METHOD constructor.

* create a new message instance
    m_msg = zcl_mqba_factory=>create_message( ).

  ENDMETHOD.


  METHOD zif_mqba_producer~get_error_text.

    CHECK m_exception IS BOUND.
    rv_text = m_exception->get_text( ).

  ENDMETHOD.


  method ZIF_MQBA_PRODUCER~GET_EXCEPTION.
    rr_exception = m_exception.
  endmethod.


  METHOD zif_mqba_producer~get_message.

* final preparations
    IF m_consumer_id IS NOT INITIAL.
      m_msg->set_scope( zif_mqba_broker=>c_scope_private ).
      m_msg->set_property( iv_name = zif_mqba_broker=>c_int_field_prefix && zif_mqba_broker=>c_int_field_consumer_id
                           iv_value = m_consumer_id ).
    ELSEIF m_external EQ abap_true.
      m_msg->set_scope( zif_mqba_broker=>c_scope_distributed ).
    ELSE.
      m_msg->set_scope( zif_mqba_broker=>c_scope_internal ).
    ENDIF.

* return current message
    rr_msg = m_msg.
  ENDMETHOD.


  METHOD zif_mqba_producer~is_failed.
    rv_failed = COND #( WHEN m_exception IS BOUND
                        THEN abap_true
                        ELSE abap_false ).
  ENDMETHOD.


  METHOD zif_mqba_producer~publish.

* ----- check and prepare
    CLEAR rv_success.

* ----- prepare message to send
    DATA(lr_msg) = zif_mqba_producer~get_message( ).

* ----- publish to broker
    DATA(lr_broker) = zcl_mqba_factory=>get_broker( ).
    IF lr_broker->internal_message_arrived( lr_msg ) EQ abap_false.
*     errors occured
      m_exception = lr_broker->get_exception( ).
    ELSE.
*     success
      rv_success = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_producer~set_consumer_id.
    m_consumer_id = iv_consumer_id.
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_producer~set_context.
    m_msg->set_context( iv_context ).
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_producer~set_external.
    m_external = abap_true.
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_producer~set_field.
    CHECK iv_name IS NOT INITIAL.
    m_msg->set_property( iv_name  = iv_name iv_value = iv_value ).
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_producer~set_payload.
    m_msg->set_payload( iv_payload ).
    rr_self = me.
  ENDMETHOD.


  method ZIF_MQBA_PRODUCER~SET_TOPIC.
     m_msg->set_topic( iv_topic ).
     rr_self = me.
  endmethod.
ENDCLASS.
