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
PARAMETERS: p_tsf   TYPE zmqba_timestamp.
SELECTION-SCREEN: ULINE.
PARAMETERS: p_rfsh  TYPE zmqba_flag_auto_refresh AS CHECKBOX DEFAULT abap_true.
PARAMETERS: p_tint  TYPE zmqba_timer_interval DEFAULT 1.

* ------ local classes
CLASS lcl_table_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_added_function FOR EVENT added_function OF cl_salv_events_table
        IMPORTING e_salv_function.
ENDCLASS.                    "lcl_table_events DEFINITION

CLASS lcl_timer_event DEFINITION.
  PUBLIC SECTION.
    METHODS m_timer_finished FOR EVENT finished OF cl_gui_timer.
ENDCLASS.                    "lcl_timer_event DEFINITION


* ------- global data
DATA: gr_table       TYPE REF TO cl_salv_table.
DATA: gr_events      TYPE REF TO lcl_table_events.
DATA: gr_timer       TYPE REF TO cl_gui_timer.
DATA: gr_timer_event TYPE REF TO lcl_timer_event.
DATA: gs_result      TYPE zmqba_api_s_brk_msg.

* ----------------------------------------------------- INIT
INITIALIZATION.

*
  GET TIME STAMP FIELD p_tsf.

* ----------------------------------------------------- START
START-OF-SELECTION.

* --------- read broker memory
  PERFORM get_messages_from_broker.

* ------- check for errors
  IF gs_result-error IS NOT INITIAL.
    cl_demo_output=>display( |Error: { gs_result-error }| ).
  ELSE.
* -------- display list (empty table allowed
*     create new alv table
    cl_salv_table=>factory( IMPORTING r_salv_table = gr_table CHANGING t_table = gs_result-msg ).
*     show toolbar with all functions
    gr_table->get_functions( )->set_all( ).  " ->set_default( abap_true )
*     optimze col width
    gr_table->get_columns( )->set_optimize( ).
*     set layout
    gr_table->get_layout( )->set_save_restriction( if_salv_c_layout=>restrict_none ).
    gr_table->get_layout( )->set_key( VALUE salv_s_layout_key( report = sy-repid ) ).
*     start timer
    PERFORM timer_start.
*     display now
    gr_table->display( ).
*     stop timer
    PERFORM timer_stop.
  ENDIF.

END-OF-SELECTION.
* ================================= END OF PROGRAM =================================
CLASS lcl_table_events IMPLEMENTATION.

  METHOD on_added_function.
    BREAK-POINT.
  ENDMETHOD.                    "on_added_function

ENDCLASS.                    "lcl_table_events IMPLEMENTATION

CLASS lcl_timer_event IMPLEMENTATION.

  METHOD m_timer_finished.
    PERFORM timer_process.
  ENDMETHOD.                    "handle_finished

ENDCLASS.                    "lcl_timer_event IMPLEMENTATION
*&---------------------------------------------------------------------*
*&      Form  GET_MESSAGES_FROM_BROKER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_messages_from_broker .


* ------ get messages from memory with parameters
* get broker access
  DATA(lr_broker) = zcl_mqba_factory=>get_broker( ).
* read memory with params
  CLEAR gs_result.
  gs_result = lr_broker->get_current_memory(
    iv_filter_context    = p_ctx
    iv_filter_topic      = p_top
    iv_timestamp_from    = p_tsf
    iv_filter_sender     = p_snd
    iv_filter_sender_ref = p_sndr ).

*     status message with count
  IF gs_result-msg[] IS NOT INITIAL.
    MESSAGE s002 WITH gs_result-msg_cnt_sel gs_result-msg_cnt_all.
  ENDIF.

*     sort: newest first
  SORT gs_result-msg BY updated DESCENDING.


ENDFORM.
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
*   remember the current data selection
  DATA(lv_first) = gs_result-msg_ts_first.
  DATA(lv_last)  = gs_result-msg_ts_last.
  DATA(lv_count) = gs_result-msg_cnt_sel.
*   refresh selection
  PERFORM get_messages_from_broker.
*   check changes
  IF lv_first NE gs_result-msg_ts_first
    OR lv_last NE gs_result-msg_ts_last
    OR lv_count NE gs_result-msg_cnt_sel.
*   trigger refresh table
    PERFORM table_refresh.
  ENDIF.
*   trigger time again
  PERFORM timer_start.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TABLE_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM table_refresh .
*   set new data to table
  gr_table->refresh(
    refresh_mode = if_salv_c_refresh=>soft
    s_stable = VALUE lvc_s_stbl( col = 'X' ) ).
*   trigger gui update
  cl_gui_cfw=>flush( ).
  cl_gui_cfw=>set_new_ok_code( 'RFSH' ).
ENDFORM.
