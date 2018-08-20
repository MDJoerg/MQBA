class ZCL_MQBA_SAM_WORKFLOW_EVENT definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_SUBSCRIBER .
protected section.

  constants C_PARAM1_USAGE type STRING value 'BUS1006' ##NO_TEXT.
  constants C_PARAM2_USAGE type STRING value '100000' ##NO_TEXT.
  constants C_PARAM3_USAGE type STRING value 'CHANGED' ##NO_TEXT.
private section.
ENDCLASS.



CLASS ZCL_MQBA_SAM_WORKFLOW_EVENT IMPLEMENTATION.


  METHOD zif_mqba_subscriber~process.

* ------ local data and macros
    DATA: lv_objtype   TYPE swo_objtyp.
    DATA: lv_objkey    TYPE swo_typeid.
    DATA: lv_event     TYPE swo_event.
    DATA: lv_evtid     TYPE swe_evtid.
    DATA: lv_count     TYPE swe_evtid.

    DEFINE get_config.
      &1 = CONV &2( is_context-sub_act_cfg-&3 ).
      IF is_context-sub_cfg-&3 IS NOT INITIAL.
        &1 = is_context-sub_cfg-&3.
      ENDIF.
    END-OF-DEFINITION.


* ------ init
    rv_msg_type = 'X'.


* ------ param 1 -> objtype
    get_config lv_objtype string param1.
    IF lv_objtype IS INITIAL.
      rv_msg_type = 'A'.  " wrong config, no restart
      RETURN.
    ENDIF.

* ------ param 2 -> objkey
    get_config lv_objkey string param2.
    IF lv_objkey IS INITIAL.
      rv_msg_type = 'A'.  " wrong config, no restart
      RETURN.
    ENDIF.

* ------ param 3 -> event
    get_config lv_event string param3.
    IF lv_event IS INITIAL.
      rv_msg_type = 'A'.  " wrong config, no restart
      RETURN.
    ENDIF.


* ------ call workflow api
    CALL FUNCTION 'SWE_EVENT_CREATE'
      EXPORTING
        objtype           = lv_objtype
        objkey            = lv_objkey
        event             = lv_event
*       CREATOR           = ' '
*       TAKE_WORKITEM_REQUESTER       = ' '
*       START_WITH_DELAY  = ' '
*       START_RECFB_SYNCHRON          = ' '
*       NO_COMMIT_FOR_QUEUE           = ' '
*       DEBUG_FLAG        = ' '
*       NO_LOGGING        = ' '
*       IDENT             =
      IMPORTING
        event_id          = lv_evtid
        receiver_count    = lv_count
*     TABLES
*       EVENT_CONTAINER   =
      EXCEPTIONS
        objtype_not_found = 1
        OTHERS            = 2.
    CASE sy-subrc.
      WHEN 0.
        IF lv_count EQ 0.
          rv_msg_type = 'W'.    " warn, no receiver
        ELSE.
          rv_msg_type = 'S'.    " success, at least 1 receiver
        ENDIF.
      WHEN 1.
        rv_msg_type = 'A'.    " config error
      WHEN 2.
        rv_msg_type = 'E'.    " unknown, try again later
      WHEN OTHERS.
        rv_msg_type = 'X'.    " invalid, dump
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
