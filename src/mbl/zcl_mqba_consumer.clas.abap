class ZCL_MQBA_CONSUMER definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_CONSUMER .
  interfaces IF_AMC_MESSAGE_RECEIVER .
  interfaces IF_AMC_MESSAGE_RECEIVER_PCP .

  methods CONSTRUCTOR .
protected section.

  data M_PCP_MSG type ref to IF_AC_MESSAGE_TYPE_PCP .
  data M_CONSUMER_ID type AMC_CONSUMER_SESSION_ID .
  data M_PCP_MSG_VALID type ABAP_BOOL .
  data M_EXCEPTION type ref to CX_ROOT .
  data M_MSG type ref to ZIF_MQBA_REQUEST .
  data M_SUBSCRIPTIONS type ref to ZIF_MQBA_UTIL_RANGE .
  data M_CONTEXT type STRING .

  methods BUILD_MESSAGE .
  methods INITIALIZE .
  methods RESET .
private section.
ENDCLASS.



CLASS ZCL_MQBA_CONSUMER IMPLEMENTATION.


  METHOD build_message.

* ----- local data
    DATA: lr_msg TYPE REF TO zcl_mqba_int_message.

* ----- init and check
    CLEAR m_msg.
    CHECK m_pcp_msg IS NOT INITIAL.

* ----- create a new message
    lr_msg ?= zcl_mqba_factory=>create_message( ).

* ----- fill fields
    IF lr_msg->set_data_from_pcp( m_pcp_msg ) EQ abap_true.
* ----- store
      m_msg = lr_msg.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.
    initialize( ).
  ENDMETHOD.


  METHOD if_amc_message_receiver_pcp~receive.

    TRY.
* ---- if topic registered
        IF m_subscriptions->is_empty( ) EQ abap_false.
          DATA(lv_topic) = i_message->get_field( zif_mqba_broker=>c_int_field_prefix && zif_mqba_broker=>c_int_field_topic ).
          CHECK m_subscriptions->check( lv_topic ) EQ abap_true.
        ENDIF.

* ---- check context filter
        IF m_context IS NOT INITIAL.
          DATA(lv_context) = i_message->get_field( zif_mqba_broker=>c_int_field_prefix &&  zif_mqba_broker=>c_int_field_context ).
          CHECK m_context CP lv_context.
        ENDIF.

* ---- check session id
        DATA(lv_consumerid) = i_message->get_field( zif_mqba_broker=>c_int_field_prefix &&  zif_mqba_broker=>c_int_field_consumer_id ).
        IF lv_consumerid IS NOT INITIAL AND lv_consumerid NE m_consumer_id.
          EXIT. " not for me...
        ENDIF.


* ---- set received message an leave wait
        m_pcp_msg = i_message.
        m_pcp_msg_valid = abap_true.

* ---- error handling
      CATCH cx_ac_message_type_pcp_error
        INTO m_exception.
    ENDTRY.


  ENDMETHOD.


  METHOD initialize.

*    reset vars
    reset( ).

*    init internal helpers
    m_subscriptions = zcl_mqba_factory=>create_util_range( ).

*    reset other vars
    CLEAR m_context.

  ENDMETHOD.


  METHOD reset.
    CLEAR: m_exception,
           m_pcp_msg,
           m_pcp_msg_valid.

  ENDMETHOD.


  METHOD zif_mqba_consumer~get_consumer_id.

* ----- generate if empty
    IF m_consumer_id IS INITIAL.
      TRY.
          m_consumer_id = cl_amc_channel_manager=>get_consumer_session_id( ).
        CATCH cx_amc_error INTO DATA(id_exc).

          cl_demo_output=>display( id_exc->get_text( ) ).
      ENDTRY.

* ------ test issues
      LOG-POINT ID zmqba_int SUBKEY 'new_consumer_id'
        FIELDS m_consumer_id.

      ASSERT ID zmqba_int SUBKEY 'consumer_id'
        FIELDS m_consumer_id
        CONDITION m_consumer_id IS NOT INITIAL.
    ELSE.
      LOG-POINT ID zmqba_int SUBKEY 'old_consumer_id'
        FIELDS m_consumer_id.
    ENDIF.

* ------- result
    rv_consumer_id = m_consumer_id.


  ENDMETHOD.


  METHOD zif_mqba_consumer~get_error_text.
    CHECK m_exception IS BOUND.
    rv_err_text = m_exception->get_text( ).
  ENDMETHOD.


  METHOD zif_mqba_consumer~get_exception.
    rr_exception = m_exception.
  ENDMETHOD.


  METHOD zif_mqba_consumer~get_message.
    rr_msg = m_msg.
  ENDMETHOD.


  METHOD zif_mqba_consumer~get_message_pcp.
    rr_pcp_msg = m_pcp_msg.
  ENDMETHOD.


  METHOD zif_mqba_consumer~set_context_filter.
    m_context = iv_ctx_filter.
  ENDMETHOD.


  METHOD zif_mqba_consumer~subscribe.

* add subscription
    m_subscriptions->add( iv_topic ).

* retun me
    rr_self = me.

  ENDMETHOD.


  METHOD zif_mqba_consumer~wait_for_messages.

* ----- set timestamp
    GET TIME.

* ----- reset
    reset( ).

* ----- prepare configuration
    DATA(lv_wait_for) =  iv_wait_up_to_sec.
    IF lv_wait_for <= 0.
      lv_wait_for = 60. " seconds
    ENDIF.

* ----- bind to amc channel and wait
    TRY.
        cl_amc_channel_manager=>create_message_consumer(
            i_application_id = 'ZMQBA_INT'
            i_channel_id     = '/messages'
            )->start_message_delivery( i_receiver = me ).
      CATCH cx_amc_error INTO m_exception.
        DATA(lv_error) = m_exception->get_text( ).
        rv_success = abap_false.
        EXIT.
    ENDTRY.



* ------ wait now
    WAIT FOR MESSAGING CHANNELS
         UNTIL m_pcp_msg_valid = abap_true
         UP TO lv_wait_for SECONDS.


* ------- calc result
    rv_success = COND #( WHEN m_exception IS BOUND
                           OR m_pcp_msg_valid = abap_false
                         THEN abap_false
                         ELSE abap_true ).

* -------- post processing depending on result
    IF rv_success EQ abap_true.
      build_message( ).
    ELSE.
      m_exception = zcl_mqba_factory=>create_exception( 'timeout' ).
    ENDIF.



  ENDMETHOD.
ENDCLASS.
