class ZCL_MQBA_UTIL_SELPAR definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_UTIL_SELPAR .

  class-methods CREATE
    returning
      value(RR_INSTANCE) type ref to ZCL_MQBA_UTIL_SELPAR .
protected section.

  data M_SELPAR type RSPARAMS_TT .
private section.
ENDCLASS.



CLASS ZCL_MQBA_UTIL_SELPAR IMPLEMENTATION.


  METHOD create.
    rr_instance = NEW zcl_mqba_util_selpar( ).
  ENDMETHOD.


  METHOD zif_mqba_util_selpar~add_from_prog_context.

* --- local data
    DATA: lv_count  TYPE i.
    DATA: ls_selpar LIKE LINE OF m_selpar.
    DATA: lv_repid  TYPE syrepid.
    FIELD-SYMBOLS: <lfs_par> TYPE data.
    FIELD-SYMBOLS: <lfs_t_sel> TYPE table.
    FIELD-SYMBOLS: <lfs_s_sel> TYPE data.

* ---- prepare
    lv_repid = iv_prog.
    IF lv_repid IS INITIAL.
      lv_repid = iv_prog.
    ENDIF.


* ---- loop all fields
    LOOP AT it_fields INTO DATA(ls_field).
*     prepare line
      CLEAR ls_selpar.
      MOVE-CORRESPONDING ls_field TO ls_selpar.
      DATA(lv_dynfld) = |({ lv_repid }){ ls_field-selname }|.

*     check par
      IF ls_field-kind EQ 'P'.
        UNASSIGN: <lfs_par>.
        ASSIGN (lv_dynfld) TO <lfs_par>.
        IF <lfs_par> IS ASSIGNED.
          ls_selpar-option = 'EQ'.
          ls_selpar-sign   = 'I'.
          ls_selpar-low    = <lfs_par>.
          APPEND ls_selpar TO m_selpar.
          ADD 1 TO lv_count.
        ENDIF.
      ELSEIF ls_field-kind EQ 'S'.
        lv_dynfld = lv_dynfld && '[]'.
        UNASSIGN: <lfs_t_sel>.
        ASSIGN (lv_dynfld) TO <lfs_t_sel>.
        IF <lfs_t_sel> IS ASSIGNED.
          LOOP AT <lfs_t_sel> ASSIGNING <lfs_s_sel>.
            MOVE-CORRESPONDING <lfs_s_sel> TO ls_selpar.
            APPEND ls_selpar TO m_selpar.
            ADD 1 TO lv_count.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.

* ------- check
    rv_success = COND #( WHEN lv_count = 0
                         THEN abap_false
                         ELSE abap_true ).

  ENDMETHOD.


  METHOD zif_mqba_util_selpar~add_from_selection_screen.

* --- local data
    DATA: lv_repid TYPE progname.
    DATA: lv_dynnr TYPE sydynnr.

* ---- prepare
    lv_repid = sy-cprog.
    lv_dynnr = sy-dynnr.


* ------ get fields from dynpro
    DATA(lt_fields) = zcl_mqba_gui_factory=>get_gui_util( )->get_dynpro_params( EXPORTING iv_prog = lv_repid iv_dynnr = lv_dynnr ).

* ------ get all fields via program context
    IF lt_fields[] IS INITIAL.
      rv_success = abap_false.
    ELSE.
      rv_success =  zif_mqba_util_selpar~add_from_prog_context(
                        it_fields  = lt_fields
                        iv_prog    = lv_repid ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_util_selpar~fill_structure.

* --- loop at internal selpar table for params
    LOOP AT m_selpar INTO DATA(ls_selpar)
        WHERE kind EQ 'P'.
      ASSIGN COMPONENT ls_selpar-selname OF STRUCTURE cs_struc
        TO FIELD-SYMBOL(<lfs_param>).
      IF <lfs_param> IS ASSIGNED.
        IF <lfs_param> IS INITIAL OR iv_overwrite EQ abap_true.
          <lfs_param> = ls_selpar-low.
        ENDIF.
      ENDIF.
    ENDLOOP.

* --- next loop at seloptions when no interval is available
    IF iv_with_selopt EQ abap_true.
      LOOP AT m_selpar INTO DATA(ls_selopt)
          WHERE kind EQ 'S'
            AND sign EQ 'I'
            AND high EQ space
            AND low  NE space
            AND ( option EQ 'EQ' OR option EQ 'CP' ).
        ASSIGN COMPONENT ls_selopt-selname OF STRUCTURE cs_struc
          TO FIELD-SYMBOL(<lfs_selopt>).
        IF <lfs_selopt> IS ASSIGNED.
          IF <lfs_selopt> IS INITIAL OR iv_overwrite EQ abap_true.
            <lfs_selopt> = ls_selopt-low.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_util_selpar~get_all.
    rt_params = m_selpar.
  ENDMETHOD.


  METHOD zif_mqba_util_selpar~get_as_range.

* --- get a fresh instance
    rr_range = zcl_mqba_factory=>create_util_range( ).

* --- loop at internal selpar table
    LOOP AT m_selpar INTO DATA(ls_selpar)
        WHERE selname EQ iv_param.
      rr_range->add_rsparams( ls_selpar ).
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_mqba_util_selpar~get_param.

    READ TABLE m_selpar INTO DATA(ls_selpar)
      WITH KEY selname = iv_param
               kind = 'P'.
    rv_string = ls_selpar-low.

  ENDMETHOD.
ENDCLASS.
