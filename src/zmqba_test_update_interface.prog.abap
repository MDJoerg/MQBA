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
PARAMETERS: p_tsf   TYPE zmqba_timestamp DEFAULT sy-datum.
SELECTION-SCREEN: ULINE.
PARAMETERS: p_tint  TYPE zmqba_timer_interval DEFAULT 5.

* ------ local classes
CLASS lcl_timer_event DEFINITION.
  PUBLIC SECTION.
    METHODS m_timer_finished FOR EVENT finished OF cl_gui_timer.
ENDCLASS.                    "lcl_timer_event DEFINITION


* ------- global data
DATA: gr_timer       TYPE REF TO cl_gui_timer.
DATA: gr_timer_event TYPE REF TO lcl_timer_event.
DATA: gv_timer_cnt   TYPE i.


* ----------------------------------------------------- INIT
INITIALIZATION.

  PERFORM timer_start.


* ----------------------------------------------------- START
START-OF-SELECTION.

  PERFORM timer_stop.

  WRITE: / 'executed:', p_ctx, gv_timer_cnt.

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

  ADD 1 TO gv_timer_cnt.
  p_ctx = gv_timer_cnt.

  DATA: lt_fields TYPE TABLE OF dynpread.
  DATA: ls_field LIKE LINE OF lt_fields.

  ls_field-fieldname   = 'P_CTX'.
  ls_field-fieldvalue  = |{ gv_timer_cnt }|.
  ls_field-fieldinp    = 'X'.
  APPEND ls_field TO lt_fields.


  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = lt_fields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


*   do something
*   trigger gui update
  cl_gui_cfw=>flush( ).
  cl_gui_cfw=>set_new_ok_code( 'RFSH' ).
*   trigger time again
  PERFORM timer_start.
ENDFORM.
