class ZCL_MQBA_GUI_WIDGET_SWT definition
  public
  inheriting from ZCL_MQBA_GUI_WIDGET
  create public .

public section.

  methods ZIF_MQBA_GUI_SUBSCREEN~PAI
    redefinition .
  methods ZIF_MQBA_GUI_WIDGET~HANDLE_OKCODE
    redefinition .
  methods ZIF_MQBA_GUI_WIDGET~SET_FROM_CFG
    redefinition .
  methods ZIF_MQBA_GUI_WIDGET~UPDATE_UI
    redefinition .
protected section.

  data M_VALUE_ON type STRING .
  data M_VALUE_OFF type STRING .
  data C_ICON_RED type ICON_D value '@5C@' ##NO_TEXT.
  data C_ICON_GREEN type ICON_D value '@5B@' ##NO_TEXT.
  data C_ICON_YELLOW type ICON_D value '@5D@' ##NO_TEXT.

  methods INITIALIZE
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_MQBA_GUI_WIDGET_SWT IMPLEMENTATION.


  METHOD INITIALIZE.

* ------- call super
    super->initialize( ).

* ------- prepare subscreen mode
    m_subscreen_program = 'SAPLZMQBA_GUI_WIDGET'.
    m_subscreen_bdynnr  = '2100'.

  ENDMETHOD.


  METHOD zif_mqba_gui_subscreen~pai.

* ---- call super
    super->zif_mqba_gui_subscreen~pai(
      CHANGING
        cs_uidata = cs_uidata
        cv_ucomm  =  cv_ucomm
    ).

* ---- check for button and append my index
    IF sy-ucomm EQ 'BT_SWITCH'.
      IF m_publish IS NOT INITIAL.
*        switch
        DATA(lv_payload) = COND #( WHEN m_cur = m_value_on
                                   THEN m_value_off
                                   ELSE m_value_on ).
*        publish
        IF publish( lv_payload ) EQ abap_true.
          CLEAR cv_ucomm.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  method ZIF_MQBA_GUI_WIDGET~HANDLE_OKCODE.
*CALL METHOD SUPER->ZIF_MQBA_GUI_WIDGET~HANDLE_OKCODE
*  CHANGING
*    CV_OKCODE =
*    .
  endmethod.


  METHOD zif_mqba_gui_widget~set_from_cfg.

*   get additional data switch
    get_prop_from_cfg_struc( EXPORTING is_cfg  = is_config iv_name = 'VALON'   CHANGING cv_prop = m_value_on ).
    get_prop_from_cfg_struc( EXPORTING is_cfg  = is_config iv_name = 'VALOF'   CHANGING cv_prop = m_value_off ).

*   call super
    rr_self = super->zif_mqba_gui_widget~set_from_cfg( is_config ).

  ENDMETHOD.


  METHOD zif_mqba_gui_widget~update_ui.

    DEFINE set_field.
      set_ui_field( EXPORTING iv_name = &1  iv_value   = &2 iv_subscreen = iv_subscreen CHANGING cs_uidata = cs_uidata ).
    END-OF-DEFINITION.


* ------ call super
    super->zif_mqba_gui_widget~update_ui( EXPORTING iv_subscreen = iv_subscreen CHANGING cs_uidata = cs_uidata ).

* ------ additional icon
    DATA: lv_icon TYPE zmqba_gui_icon.

    IF m_cur = m_value_on.
      lv_icon = c_icon_green.
    ELSEIF m_cur = m_value_off.
      lv_icon = c_icon_red.
    ELSE.
      lv_icon = c_icon_yellow.
    ENDIF.

    set_field 'ICON'     lv_icon.

  ENDMETHOD.
ENDCLASS.
