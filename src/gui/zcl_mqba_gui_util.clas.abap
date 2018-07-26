class ZCL_MQBA_GUI_UTIL definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_GUI_UTIL .

  class-methods CREATE
    returning
      value(RR_INSTANCE) type ref to ZCL_MQBA_GUI_UTIL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MQBA_GUI_UTIL IMPLEMENTATION.


  METHOD create.
    rr_instance = NEW zcl_mqba_gui_util( ).
  ENDMETHOD.


  METHOD zif_mqba_gui_util~get_dynpro_params.

* ------ local data
    DATA: lv_repid    TYPE progname.
    DATA: lv_dynnr    TYPE sydynnr.
    DATA: ls_header   TYPE d020s.
    DATA: lt_fields   TYPE TABLE OF d021s.
    DATA: lt_flow     TYPE dyn_flowlist.
    DATA: lt_params   TYPE TABLE OF d023s.
    DATA: ls_line     LIKE LINE OF rt_fields.
    DATA: lv_dummy    TYPE string.


* ------ prepare call
    lv_repid = iv_prog.
    lv_dynnr = iv_dynnr.


* ------ call scrp
    CALL FUNCTION 'RS_SCRP_DYNPRO_READ_NATIVE'
      EXPORTING
        progname  = lv_repid
        dynnr     = lv_dynnr
      IMPORTING
        header    = ls_header
      TABLES
        fieldlist = lt_fields
        flowlogic = lt_flow
        params    = lt_params
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

* ------ post processing
    LOOP AT lt_fields INTO DATA(ls_field).
      IF ls_field-fnam CP '%_*'.
      ELSEIF ls_field-fnam EQ 'SSCRFIELDS-UCOMM'.
      ELSEIF ls_field-fnam CP '*-HIGH'.
      ELSEIF ls_field-fnam CP '*-LOW'.
        SPLIT ls_field-fnam AT '-' INTO   ls_line-selname lv_dummy.
        ls_line-kind    = 'S'.
        APPEND ls_line TO rt_fields.
      ELSE.
        ls_line-selname = ls_field-fnam.
        ls_line-kind    = 'P'.
        APPEND ls_line TO rt_fields.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
