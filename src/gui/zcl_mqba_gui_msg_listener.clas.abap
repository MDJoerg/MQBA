class ZCL_MQBA_GUI_MSG_LISTENER definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_GUI_MSG_LISTENER .

  class-methods CREATE
    returning
      value(RR_INSTANCE) type ref to ZIF_MQBA_GUI_MSG_LISTENER .
protected section.

  data M_INTERVAL type I value 1 ##NO_TEXT.
  data M_TIMER type ref to CL_GUI_TIMER .
  data M_MSGS type ZMQBA_API_S_BRK_MSG .
  data M_TOPIC_RANGE type ref to ZIF_MQBA_UTIL_RANGE .
  data M_LAST_MSG type ZMQBA_TIMESTAMP .
  data M_DELTA_MODE type ABAP_BOOL .

  methods ON_TIMER_EVENT
    for event FINISHED of CL_GUI_TIMER .
private section.
ENDCLASS.



CLASS ZCL_MQBA_GUI_MSG_LISTENER IMPLEMENTATION.


  METHOD create.
    rr_instance = NEW zcl_mqba_gui_msg_listener( ).
  ENDMETHOD.


  METHOD on_timer_event.

* ------ local data
    DATA: lv_error     TYPE abap_bool.
    DATA: lt_valid     TYPE zmqba_msg_t_main.
    DATA: lv_timestamp TYPE zmqba_timestamp.

* ------ stop current timer
    zif_mqba_gui_msg_listener~stop( ).

* ------ check for timestamp
    IF m_delta_mode EQ abap_true.
      lv_timestamp = m_last_msg.
    ENDIF.

* ------ get current msg from memory with filter
    CALL FUNCTION 'Z_MQBA_API_BROKER_GET_MEMORY'
      EXPORTING
*       IV_TOPIC     =
*       IV_SENDER    =
*       IV_SENDER_REF       =
*       IV_CONTEXT   =
        iv_time_from = lv_timestamp
      IMPORTING
        es_data      = m_msgs
        ev_error     = lv_error.

* ------ store timestamp
    IF m_msgs-msg_ts_last IS NOT INITIAL.
      m_last_msg = m_msgs-msg_ts_last.
    ENDIF.

* ------ check data against topic filter
    IF m_msgs-msg[] IS NOT INITIAL.
      IF m_topic_range IS NOT INITIAL AND m_topic_range->get_count( ) GT 0.
*       loop and check
        LOOP AT m_msgs-msg INTO DATA(ls_msg).
          IF ls_msg-topic IN m_topic_range->get_range( ).
            APPEND ls_msg TO lt_valid.
          ENDIF.
        ENDLOOP.
      ELSE.
*       set all
        lt_valid = m_msgs-msg[].
      ENDIF.
*     raise event
      IF lt_valid[] IS NOT INITIAL.
        RAISE EVENT zif_mqba_gui_msg_listener~on_msg_arrived
          EXPORTING
            it_msg = lt_valid
            .
      ENDIF.
    ENDIF.


* ------ restart timer
    zif_mqba_gui_msg_listener~start( ).

  ENDMETHOD.


  METHOD zif_mqba_gui_msg_listener~destroy.

* ------ stop now
    zif_mqba_gui_msg_listener~stop( ).

  ENDMETHOD.


  METHOD zif_mqba_gui_msg_listener~get_last_data.
    rs_data = m_msgs.
  ENDMETHOD.


  METHOD zif_mqba_gui_msg_listener~get_timestamp_last.
    ev_last = m_last_msg.
  ENDMETHOD.


  method ZIF_MQBA_GUI_MSG_LISTENER~IS_STARTED.
    rv_started = COND #( when m_timer is NOT INITIAL
                         then abap_true
                         else abap_false ).
  endmethod.


  METHOD zif_mqba_gui_msg_listener~set_delta_mode.
    m_delta_mode = iv_activate.
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_gui_msg_listener~set_interval.
    IF iv_interval GT 0.
      m_interval = iv_interval.
    ELSE.
      m_interval = 5.
    ENDIF.
  ENDMETHOD.


  METHOD zif_mqba_gui_msg_listener~start.

* ----- check started already
    IF zif_mqba_gui_msg_listener~is_started( ) EQ abap_true.
      rv_success = abap_false.
    ELSE.
* ----- create and start timer
      CREATE OBJECT m_timer.
      SET HANDLER on_timer_event  FOR m_timer.
*   set interval
      IF m_interval GT 0.
        MOVE m_interval TO m_timer->interval.
      ELSE.
        m_timer->interval = 5.
      ENDIF.
*   start now
      m_timer->run( ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_gui_msg_listener~stop.

    IF m_timer IS NOT INITIAL.
      m_timer->cancel( ).
      CLEAR m_timer.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_gui_msg_listener~subscribe_to.

*  check range is initialized
    IF m_topic_range IS INITIAL.
      m_topic_range = zcl_mqba_factory=>create_util_range( ).
    ENDIF.

*   add to range
    IF iv_topic IS NOT INITIAL.
      m_topic_range->add( iv_topic ).
    ENDIF.

*   return myself
    rr_self = me.

  ENDMETHOD.
ENDCLASS.
