class ZCL_MQBA_GUI_WIDGET_HOLDER definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_GUI_WIDGET_HOLDER .

  class-methods CREATE
    returning
      value(RR_INSTANCE) type ref to ZCL_MQBA_GUI_WIDGET_HOLDER .
protected section.

  data M_WIDGETS type ZMQBA_GUI_T_WIDGET .
private section.
ENDCLASS.



CLASS ZCL_MQBA_GUI_WIDGET_HOLDER IMPLEMENTATION.


  METHOD create.
    rr_instance = NEW zcl_mqba_gui_widget_holder( ).
  ENDMETHOD.


  METHOD zif_mqba_gui_widget_holder~add.

    IF ir_widget IS NOT INITIAL.
      APPEND INITIAL LINE TO m_widgets ASSIGNING FIELD-SYMBOL(<new>).
      <new>-cfg_idx = ir_widget->get_cfg_idx( ).
      <new>-widget  = ir_widget.
    ENDIF.

    rr_self = me.

  ENDMETHOD.


  METHOD zif_mqba_gui_widget_holder~get_count.
    DESCRIBE TABLE m_widgets LINES rv_count.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget_holder~get_widget.

*   check input
    CHECK iv_index GT 0
      AND iv_index <= zif_mqba_gui_widget_holder~get_count( ).

*   read widget table
    READ TABLE m_widgets INTO DATA(ls_line) INDEX iv_index.
    rr_widget = ls_line-widget.

  ENDMETHOD.


  METHOD zif_mqba_gui_widget_holder~handle_payload.

    LOOP AT m_widgets INTO DATA(ls_widget).

      IF ls_widget-widget->handle_payload(
          iv_topic   = iv_topic
          iv_payload = iv_payload
          iv_updated = iv_updated ) EQ abap_true.
        ADD 1 TO rv_handled_count.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
