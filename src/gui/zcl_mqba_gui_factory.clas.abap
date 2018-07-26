class ZCL_MQBA_GUI_FACTORY definition
  public
  final
  create public .

public section.

  class-methods CREATE_LISTENER
    returning
      value(RR_LISTENER) type ref to ZIF_MQBA_GUI_MSG_LISTENER .
  class-methods CREATE_WIDGET
    importing
      !IV_TYPE type DATA optional
    returning
      value(RR_WIDGET) type ref to ZIF_MQBA_GUI_WIDGET .
  class-methods CREATE_WIDGET_HOLDER
    returning
      value(RR_WIDGET_HOLDER) type ref to ZIF_MQBA_GUI_WIDGET_HOLDER .
  class-methods GET_GUI_UTIL
    returning
      value(RR_UTIL) type ref to ZIF_MQBA_GUI_UTIL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MQBA_GUI_FACTORY IMPLEMENTATION.


  METHOD create_listener.
    rr_listener = zcl_mqba_gui_msg_listener=>create( ).
  ENDMETHOD.


  METHOD create_widget.
    rr_widget = zcl_mqba_gui_widget=>create( iv_type ).
  ENDMETHOD.


  METHOD create_widget_holder.
    rr_widget_holder = zcl_mqba_gui_widget_holder=>create( ).
  ENDMETHOD.


  METHOD get_gui_util.
    rr_util = zcl_mqba_gui_util=>create( ).
  ENDMETHOD.
ENDCLASS.
