*&---------------------------------------------------------------------*
*& Report ZMQBA_DAEMON_CONTROL
*&---------------------------------------------------------------------*
*& Controls a Daemon for MQBA
*&---------------------------------------------------------------------*
REPORT zmqba_daemon_control NO STANDARD PAGE HEADING.


TABLES: ztc_mqbabrk.
PARAMETERS: p_broker  LIKE ztc_mqbabrk-broker_id OBLIGATORY.
SELECTION-SCREEN: ULINE.
PARAMETERS: p_check     type zmqba_flag_check   RADIOBUTTON GROUP grp1 DEFAULT 'X'.
PARAMETERS: p_start     type zmqba_flag_start   RADIOBUTTON GROUP grp1.
PARAMETERS: p_stop      type zmqba_flag_stop    RADIOBUTTON GROUP grp1.
PARAMETERS: p_restrt    type zmqba_flag_restart RADIOBUTTON GROUP grp1.

START-OF-SELECTION.

  DEFINE exit_error.
    WRITE: / &1 COLOR 6.
    RETURN.
  END-OF-DEFINITION.

  DEFINE output.
    WRITE: / &1.
  END-OF-DEFINITION.


* ------- create broker config
  DATA(lr_mgr) = zcl_mqba_factory=>get_daemon_mgr( p_broker ).
  IF lr_mgr IS INITIAL.
    " wrong or missing config
    exit_error 'wrong broker config'.
  ENDIF.

* -------- process command
  CASE 'X'.
    WHEN p_check.
      IF lr_mgr->is_available( ) EQ abap_true.
        output 'daemon available'.
      ELSE.
        exit_error 'daemon not available'.
      ENDIF.
    WHEN p_start.
      IF lr_mgr->start( ) EQ abap_true.
        output 'daemon started'.
      ELSE.
        exit_error 'start daemon failed'.
      ENDIF.
    WHEN p_stop.
      IF lr_mgr->stop( ) EQ abap_true.
        output 'daemon stopped'.
      ELSE.
        exit_error 'stop daemon failed'.
      ENDIF.
    WHEN p_restrt.
      IF lr_mgr->restart( ) EQ abap_true.
        output 'daemon restarted'.
      ELSE.
        exit_error 'restart daemon failed'.
      ENDIF.
    WHEN OTHERS.
      exit_error 'unknown option'.
  ENDCASE.
