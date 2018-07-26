interface ZIF_MQBA_GUI_WIDGET_HOLDER
  public .


  methods ADD
    importing
      !IR_WIDGET type ref to ZIF_MQBA_GUI_WIDGET
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_WIDGET_HOLDER .
  methods GET_COUNT
    returning
      value(RV_COUNT) type I .
  methods GET_WIDGET
    importing
      !IV_INDEX type I
    returning
      value(RR_WIDGET) type ref to ZIF_MQBA_GUI_WIDGET .
  methods HANDLE_PAYLOAD
    importing
      !IV_TOPIC type DATA
      !IV_PAYLOAD type DATA
      !IV_UPDATED type ZMQBA_TIMESTAMP optional
    returning
      value(RV_HANDLED_COUNT) type I .
endinterface.
