class ZCL_MQBA_GUI_BL definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_GUI_BL .

  methods HANDLE_OKCODE
    importing
      !IV_OKCODE type SYUCOMM
    returning
      value(RV_NEXT_DYNNR) type SYDYNNR .
protected section.

  data M_OKCODE type SYUCOMM .
  data M_FIRST_PBO type ABAP_BOOL value ABAP_TRUE ##NO_TEXT.
  data M_PARAMS type ref to ZIF_MQBA_UTIL_SELPAR .
  data M_NEW_DATA type ABAP_BOOL .

  methods ON_FIRST_PBO .
  methods SET_NEW_UIDATA .
private section.
ENDCLASS.



CLASS ZCL_MQBA_GUI_BL IMPLEMENTATION.


  METHOD handle_okcode.

* --- set default next screen to current
    rv_next_dynnr = sy-dynnr.

* ---- process
    CASE m_okcode.
      WHEN 'RFSH'.
      WHEN 'CANC' OR 'EXIT' OR 'BACK'.
        rv_next_dynnr = 0.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  method ON_FIRST_PBO.
  endmethod.


  METHOD set_new_uidata.

* skip next pbo transfer and trigger rfsh
    m_new_data = abap_true.
    cl_gui_cfw=>set_new_ok_code( 'RFSH' ).

  ENDMETHOD.


  METHOD zif_mqba_gui_bl~collect_params.
* ---- create selpar helper and fill data from current program
    m_params = zcl_mqba_factory=>create_util_selpar( ).
    rv_success = m_params->add_from_selection_screen( iv_prog = sy-cprog iv_dynnr = sy-dynnr ).
  ENDMETHOD.


  method ZIF_MQBA_GUI_BL~DESTROY.
  endmethod.


  METHOD zif_mqba_gui_bl~get_parameters.
    rr_params = m_params.
  ENDMETHOD.


  METHOD zif_mqba_gui_bl~get_subscreen.

    DATA(lt_subscreen) = zif_mqba_gui_bl~get_subscreens( ).
    CHECK lt_subscreen[] IS NOT INITIAL.

    LOOP AT lt_subscreen INTO DATA(lr_subscreen).
      IF lr_subscreen->get_container( ) EQ iv_container.
        rr_subscreen = lr_subscreen.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  method ZIF_MQBA_GUI_BL~GET_SUBSCREENS.
      " redefine this
  endmethod.


  METHOD zif_mqba_gui_bl~pai.

* ---- get all data from controls first
    cl_gui_cfw=>dispatch( ).

* ---- save okcode and reset
    m_okcode = cv_okcode.
    CLEAR cv_okcode.

* ---- store uidata to internal
    IF m_new_data EQ abap_true.
      m_new_data = abap_false.
    ELSE.
      ASSIGN ('M_UIDATA') TO FIELD-SYMBOL(<uidata>).
      IF <uidata> IS ASSIGNED.
        MOVE-CORRESPONDING cs_uidata TO <uidata>.
      ENDIF.
    ENDIF.

* ---- set default next dynnr
    ev_next_dynnr = sy-dynnr.


* ---- handle okcode
    IF m_okcode IS NOT INITIAL.
      ev_next_dynnr = handle_okcode( m_okcode ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_gui_bl~pbo.

* ---- check set data from internal uidata
    ASSIGN ('M_UIDATA') TO FIELD-SYMBOL(<uidata>).
    IF <uidata> IS ASSIGNED.
      MOVE-CORRESPONDING <uidata> TO cs_uidata.
    ENDIF.

* ---- check for first pbo
    IF m_first_pbo EQ abap_true.
      on_first_pbo( ).
      m_first_pbo = abap_false.
    ENDIF.


* ----- set default to current dynpro
    ev_titlebar = sy-dynnr.
    ev_status   = sy-dynnr.

  ENDMETHOD.
ENDCLASS.
