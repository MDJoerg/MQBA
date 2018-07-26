class ZCL_MQBA_GUI_WIDGET_SEN definition
  public
  inheriting from ZCL_MQBA_GUI_WIDGET
  create public .

public section.
protected section.

  methods INITIALIZE
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_MQBA_GUI_WIDGET_SEN IMPLEMENTATION.


  METHOD initialize.

* ------- call super
    super->initialize( ).

* ------- prepare subscreen mode
    m_subscreen_program = 'SAPLZMQBA_GUI_WIDGET'.
    m_subscreen_bdynnr  = '2000'.

  ENDMETHOD.
ENDCLASS.
