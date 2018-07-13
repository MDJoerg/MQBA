*&---------------------------------------------------------------------*
*& Report ZMQBA_TEST_BROKER_MSG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmqba_broker_msg_list NO STANDARD PAGE HEADING
  MESSAGE-ID zmqba.

* ------ interface
PARAMETERS: p_top   TYPE zmqba_topic DEFAULT '*'.
PARAMETERS: p_ctx   TYPE zmqba_context.
PARAMETERS: p_snd   TYPE zmqba_sender.
PARAMETERS: p_sndr  TYPE zmqba_sender_ref.
SELECTION-SCREEN: ULINE.
PARAMETERS: p_rfsh  TYPE zmqba_flag_auto_refresh AS CHECKBOX DEFAULT 'X'.
PARAMETERS: p_tint  TYPE zmqba_timer_interval DEFAULT 5.

* ------ local classes
CLASS lcl_timer_event DEFINITION.
  PUBLIC SECTION.
    METHODS m_timer_finished FOR EVENT finished OF cl_gui_timer.
ENDCLASS.                    "lcl_timer_event DEFINITION


* ------- global data
DATA: gr_timer       TYPE REF TO cl_gui_timer.
DATA: gr_timer_event TYPE REF TO lcl_timer_event.
DATA: gs_result      TYPE zmqba_api_s_brk_msg.
DATA: gv_ts_last     LIKE gs_result-msg_ts_last.

* ----------------------------------------------------- INIT
INITIALIZATION.



* ----------------------------------------------------- START
START-OF-SELECTION.

  WRITE: / 'Started...'.
  PERFORM get_messages_from_broker .

  PERFORM timer_start.




END-OF-SELECTION.
* ================================= END OF PROGRAM =================================
CLASS lcl_timer_event IMPLEMENTATION.

  METHOD m_timer_finished.
    PERFORM timer_process.
  ENDMETHOD.                    "handle_finished

ENDCLASS.                    "lcl_timer_event IMPLEMENTATION
*&---------------------------------------------------------------------*
*&      Form  GET_MESSAGES_FROM_BROKER

*&---------------------------------------------------------------------*
*&      Form  TIMER_START
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM timer_start .
  IF p_rfsh EQ abap_true.
* create the timer if wanted at first run
    IF gr_timer IS INITIAL.
      CREATE OBJECT gr_timer.
      CREATE OBJECT gr_timer_event.
      SET HANDLER gr_timer_event->m_timer_finished FOR gr_timer.

*     set interval
      DATA(lv_interval) = COND #( WHEN p_tint < 1
                                  THEN 5
                                  ELSE p_tint ).
      MOVE lv_interval TO gr_timer->interval.
      MESSAGE s001 WITH lv_interval.
    ENDIF.

* (re)start timer
    gr_timer->run( ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TIMER_STOP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM timer_stop .
  IF gr_timer IS NOT INITIAL.
    gr_timer->cancel( ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TIMER_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM timer_process .
*   stop timer
  PERFORM timer_stop.

*   get current broker messages
  PERFORM get_messages_from_broker.

*   trigger time again
  PERFORM timer_start.
ENDFORM.

FORM get_messages_from_broker .


* ------ get messages from memory with parameters
* get broker access
  DATA(lr_broker) = zcl_mqba_factory=>get_broker( ).
* read memory with params
  CLEAR gs_result.
  gs_result = lr_broker->get_current_memory(
    iv_filter_context    = p_ctx
    iv_filter_topic      = p_top
    iv_timestamp_from    = gv_ts_last
    iv_filter_sender     = p_snd
    iv_filter_sender_ref = p_sndr ).

*     status message with count
  IF gs_result-msg[] IS INITIAL.
    MESSAGE s002 WITH gs_result-msg_cnt_sel gs_result-msg_cnt_all.
  ELSE.
*     sort: newest first
    SORT gs_result-msg BY updated DESCENDING.
*   output
    LOOP AT gs_result-msg INTO DATA(ls_line).
      WRITE: / ls_line-updated,
               ls_line-repeats,
               ls_line-topic,
               ls_line-payload.
    ENDLOOP.


*   store last timstamp
    IF gs_result-msg_ts_last IS NOT INITIAL.
      gv_ts_last = gs_result-msg_ts_last.
    ENDIF.

  ENDIF.

ENDFORM.
