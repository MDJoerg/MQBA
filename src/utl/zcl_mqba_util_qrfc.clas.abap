class ZCL_MQBA_UTIL_QRFC definition
  public
  final
  create public .

public section.
  type-pools ABAP .

  interfaces ZIF_MQBA_UTIL_QRFC .

  class-methods CREATE
    returning
      value(RR_INSTANCE) type ref to ZCL_MQBA_UTIL_QRFC .
protected section.

*"* protected components of class ZCL_MQBA_UTIL_QRFC
*"* do not include other source files here!!!
  class-data INSTANCE type ref to ZCL_MQBA_UTIL_QRFC .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQBA_UTIL_QRFC IMPLEMENTATION.


  METHOD create.
    rr_instance = NEW zcl_mqba_util_qrfc( ).
  ENDMETHOD.


  method ZIF_MQBA_UTIL_QRFC~BUILD_QUEUE_NAME.
* ------ local data
    DATA: lv_temp TYPE string.

    DEFINE add_string.
      IF &1 IS NOT INITIAL.
        lv_temp = &1.
        CONDENSE lv_temp.

        IF ev_name IS INITIAL.
          ev_name = lv_temp.
        ELSE.
          CONCATENATE ev_name lv_temp INTO ev_name.
        ENDIF.
      ENDIF.
    END-OF-DEFINITION.

* ------ init
    CLEAR ev_name.

* ------ append string
    add_string iv_prefix.
    add_string iv_name.
    add_string iv_postfix.

  endmethod.


  method ZIF_MQBA_UTIL_QRFC~DESTROY.
  endmethod.


  method ZIF_MQBA_UTIL_QRFC~GET_QIN_SIZE.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.

* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.

    CALL FUNCTION 'TRFC_GET_QIN_INFO'
      EXPORTING
        qname  = lv_queue
        client = sy-mandt
      IMPORTING
        qdeep  = ev_size.

  endmethod.


  method ZIF_MQBA_UTIL_QRFC~GET_QIN_STATUS.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.
    DATA: lt_err    TYPE TABLE OF trfcqview.
    DATA: lt_all    TYPE TABLE OF trfcqin.
    DATA: ls_all    LIKE LINE OF lt_all.
    DATA: lv_size   TYPE i.



* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.

    CALL FUNCTION 'TRFC_QIN_GET_HANGING_QUEUES'
      EXPORTING
        qname     = lv_queue
        client    = sy-mandt
      TABLES
        err_queue = lt_err
        qtable    = lt_all.

    DESCRIBE TABLE lt_all LINES lv_size.
    CHECK lv_size EQ 1.

    READ TABLE lt_all INTO ls_all INDEX 1.
    ev_status = ls_all-qstate.


  endmethod.


  method ZIF_MQBA_UTIL_QRFC~GET_QOUT_SIZE.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.
    DATA: lv_dest   TYPE rfcdest.


* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.
    lv_dest  = iv_dest.


    CALL FUNCTION 'TRFC_GET_QUEUE_INFO'
      EXPORTING
        qname  = lv_queue
        dest   = lv_dest
        client = sy-mandt
*       DIST_GET_QUEUE       = ' '
*       QDTABNAME            = ' '
      IMPORTING
        qdeep  = ev_size.


  endmethod.


  method ZIF_MQBA_UTIL_QRFC~GET_QOUT_STATUS.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.
    DATA: lv_dest   TYPE rfcdest.
    DATA: lt_err    TYPE TABLE OF trfcqview.
    DATA: lt_all    TYPE TABLE OF trfcqin.
    DATA: ls_all    LIKE LINE OF lt_all.
    DATA: lv_size   TYPE i.



* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.
    lv_dest  = iv_dest.

    CALL FUNCTION 'TRFC_QOUT_GET_HANGING_QUEUES'
      EXPORTING
        qname     = lv_queue
        dest      = lv_dest
        client    = sy-mandt
      TABLES
        err_queue = lt_err
        qtable    = lt_all.

    DESCRIBE TABLE lt_all LINES lv_size.
    CHECK lv_size EQ 1.

    READ TABLE lt_all INTO ls_all INDEX 1.
    ev_status = ls_all-qstate.


  endmethod.


  METHOD zif_mqba_util_qrfc~get_rfc_dest_from_logsys.

* ------ check empty
    IF iv_logsys IS INITIAL.
      rv_rfcdest = 'NONE'.
    ENDIF.

* ------ get it from BD97 transaction
    SELECT SINGLE rfcdest
      FROM tblsysdest
      INTO rv_rfcdest
     WHERE logsys = iv_logsys.

  ENDMETHOD.


  method ZIF_MQBA_UTIL_QRFC~GET_TRANSACTION_ID.

* ------ local data
    DATA: ls_tid TYPE arfctid.

    CALL FUNCTION 'ARFC_GET_TID'
      IMPORTING
        tid = ls_tid.
    .

    ev_id = ls_tid.

  endmethod.


  method ZIF_MQBA_UTIL_QRFC~IS_QIN_EXISTS.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.
    DATA: lv_size   TYPE i.

* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.

    CALL FUNCTION 'TRFC_GET_QIN_INFO'
      EXPORTING
        qname  = lv_queue
        client = sy-mandt
      IMPORTING
        qdeep  = lv_size.


    IF lv_size GT 0.
      ev_exists = abap_true.
    ELSE.
      ev_exists = abap_false.
    ENDIF.


  endmethod.


  method ZIF_MQBA_UTIL_QRFC~IS_QOUT_EXISTS.

* -------- local data
    DATA: lv_queue  TYPE trfcqnam.
    DATA: lv_dest   TYPE rfcdest.
    DATA: lv_size   TYPE i.

* -------- call qrfc api
    CHECK iv_queue IS NOT INITIAL.
    lv_queue = iv_queue.
    lv_dest  = iv_dest.


    CALL FUNCTION 'TRFC_GET_QUEUE_INFO'
      EXPORTING
        qname  = lv_queue
        dest   = lv_dest
        client = sy-mandt
*       DIST_GET_QUEUE       = ' '
*       QDTABNAME            = ' '
      IMPORTING
        qdeep  = lv_size.


    IF lv_size GT 0.
      ev_exists = abap_true.
    ELSE.
      ev_exists = abap_false.
    ENDIF.


  endmethod.


  method ZIF_MQBA_UTIL_QRFC~SET_QRFC_INBOUND.

* ------ start a new transaction
    IF iv_start_transaction EQ abap_true.
      me->ZIF_MQBA_UTIL_QRFC~transaction_begin( ).
    ENDIF.

* ------ set queue name
    CALL METHOD me->ZIF_MQBA_UTIL_QRFC~set_queue
      EXPORTING
        iv_inbound = abap_true
        iv_queue   = iv_queue
      RECEIVING
        ev_success = ev_success.

* ------ rollback transaction
    IF ev_success EQ abap_false
      AND iv_start_transaction EQ abap_true.
      me->ZIF_MQBA_UTIL_QRFC~transaction_cancel( ).
    ENDIF.


  endmethod.


  method ZIF_MQBA_UTIL_QRFC~SET_QRFC_OUTBOUND.

* ------ start a new transaction
    IF iv_start_transaction EQ abap_true.
      me->ZIF_MQBA_UTIL_QRFC~transaction_begin( ).
    ENDIF.

* ------ set queue name
    CALL METHOD me->ZIF_MQBA_UTIL_QRFC~set_queue
      EXPORTING
        iv_inbound = abap_false
        iv_queue   = iv_queue
      RECEIVING
        ev_success = ev_success.

* ------ rollback transaction
    IF ev_success EQ abap_false
      AND iv_start_transaction EQ abap_true.
      me->ZIF_MQBA_UTIL_QRFC~transaction_cancel( ).
    ENDIF.

  endmethod.


  method ZIF_MQBA_UTIL_QRFC~SET_QUEUE.

* -------- local data
    DATA: lv_queue TYPE trfcqnam.


* -------- init
    ev_success = abap_false.
    CHECK iv_queue IS NOT INITIAL.

* -------- get string
    lv_queue = iv_queue.
    CHECK lv_queue IS NOT INITIAL.


* -------- set queue name
    IF iv_inbound EQ abap_true.
      CALL FUNCTION 'TRFC_SET_QIN_PROPERTIES'
        EXPORTING
*         QOUT_NAME          = ' '
          qin_name           = lv_queue
*         QIN_COUNT          =
*         CALL_EVENT         = ' '
*         NO_EXECUTE         = ' '
        EXCEPTIONS
          invalid_queue_name = 1
          OTHERS             = 2.
      IF sy-subrc EQ 0.
        ev_success = abap_true.
      ENDIF.
    ELSE.
      CALL FUNCTION 'TRFC_SET_QUEUE_NAME'
        EXPORTING
          qname              = lv_queue
*         NOSEND             = ' '
*         TRFC_IF_SYSFAIL    = ' '
*         CALL_EVENT         = ' '
        EXCEPTIONS
          invalid_queue_name = 1
          OTHERS             = 2.
      IF sy-subrc EQ 0.
        ev_success = abap_true.
      ENDIF.
    ENDIF.


  endmethod.


  method ZIF_MQBA_UTIL_QRFC~SET_STATUS_RETRY_LATER.

* ------ local data
    DATA: lt_return TYPE TABLE OF  bapiret2.

* ------ set success
    ev_success = abap_true.

* ------ call api
    CALL FUNCTION 'TRFC_SEND_BACK'
      EXPORTING
        astate                  = 'ARETRY'
*       IF_FNAME                =
      TABLES
        arstate                 = lt_return
*       ARDATA01                =
*       ARDATA02                =
*       ARDATA03                =
*       ARDATA04                =
*       ARDATA05                =
      EXCEPTIONS
        no_trfc_or_qrfc_mode    = 1
        unknown_state           = 2
        missing_interface_fname = 3
        OTHERS                  = 4.
    IF sy-subrc <> 0.
      ev_success = abap_false.
    ELSE.
      LOOP AT lt_return TRANSPORTING NO FIELDS
        WHERE type CA 'EAX'.
        ev_success = abap_false.
      ENDLOOP.
    ENDIF.

  endmethod.


  method ZIF_MQBA_UTIL_QRFC~TRANSACTION_BEGIN.
    SET UPDATE TASK LOCAL.
  endmethod.


  method ZIF_MQBA_UTIL_QRFC~TRANSACTION_CANCEL.
    ROLLBACK WORK.
  endmethod.


  method ZIF_MQBA_UTIL_QRFC~TRANSACTION_END.
    IF iv_wait EQ abap_true.
      COMMIT WORK AND WAIT.
    ELSE.
      COMMIT WORK.
    ENDIF.
  endmethod.
ENDCLASS.
