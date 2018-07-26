interface ZIF_MQBA_GUI_MSG_LISTENER
  public .


  events ON_MSG_ARRIVED
    exporting
      value(IT_MSG) type ZMQBA_MSG_T_MAIN .

  methods DESTROY .
  methods SUBSCRIBE_TO
    importing
      !IV_TOPIC type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_MSG_LISTENER .
  methods START
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods STOP
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods IS_STARTED
    returning
      value(RV_STARTED) type ABAP_BOOL .
  methods SET_INTERVAL
    importing
      !IV_INTERVAL type I default 5
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_MSG_LISTENER .
  methods GET_TIMESTAMP_LAST
    returning
      value(EV_LAST) type ZMQBA_TIMESTAMP .
  methods GET_LAST_DATA
    returning
      value(RS_DATA) type ZMQBA_API_S_BRK_MSG .
  methods SET_DELTA_MODE
    importing
      !IV_ACTIVATE type ABAP_BOOL default ABAP_TRUE
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_MSG_LISTENER .
endinterface.
