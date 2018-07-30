class ZCL_MQBA_GUI_WIDGET_PPL definition
  public
  inheriting from ZCL_MQBA_GUI_WIDGET
  create public .

public section.

  methods ZIF_MQBA_GUI_SUBSCREEN~PAI
    redefinition .
protected section.

  methods INITIALIZE
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_MQBA_GUI_WIDGET_PPL IMPLEMENTATION.


  METHOD INITIALIZE.

* ------- call super
    super->initialize( ).

* ------- prepare subscreen mode
    m_subscreen_program = 'SAPLZMQBA_GUI_WIDGET'.
    m_subscreen_bdynnr  = '2200'.

  ENDMETHOD.


  METHOD zif_mqba_gui_subscreen~pai.

* ---- call super
    super->zif_mqba_gui_subscreen~pai(
      CHANGING
        cs_uidata = cs_uidata
        cv_ucomm  =  cv_ucomm
    ).

* ------ get my fields
    get_ui_field(
      EXPORTING
        iv_name    = 'TOPIC_PUB'
        iv_subscreen = abap_true
        is_uidata  = cs_uidata
      CHANGING
        cv_value   = m_publish ).

    get_ui_field(
      EXPORTING
        iv_name    = 'VALUE'
        iv_subscreen = abap_true
        is_uidata  = cs_uidata
      CHANGING
        cv_value   = m_cur ).


* ---- check for button and append my index
    CHECK sy-ucomm NE 'RFSH'.
    IF sy-ucomm EQ 'BT_PUBLISH'.
      IF m_publish IS NOT INITIAL.
*        publish
        IF publish( m_cur ) EQ abap_true.
          CLEAR cv_ucomm.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
