interface ZIF_MQBA_GUI_WIDGET
  public .


  constants C_TYPE_SENSOR type STRING value 'SEN' ##NO_TEXT.
  constants C_TYPE_SWITCH type STRING value 'SWT' ##NO_TEXT.
  constants C_TYPE_PUBPANEL type STRING value 'PPL' ##NO_TEXT.

  methods GET_CFG_IDX
    returning
      value(EV_IDX) type STRING .
  methods UPDATE_UI
    importing
      !IV_SUBSCREEN type ABAP_BOOL default ABAP_FALSE
    changing
      !CS_UIDATA type DATA .
  methods SET_DESCRIPTION
    importing
      !IV_DESCRIPTION type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_WIDGET .
  methods GET_SUBSCRIBE_TOPIC
    returning
      value(RV_TOPIC) type STRING .
  methods SET_SUBSCRIBE_TOPIC
    importing
      !IV_TOPIC type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_WIDGET .
  methods GET_PUBLISH_TOPIC
    returning
      value(RV_TOPIC) type STRING .
  methods HANDLE_OKCODE
    changing
      !CV_OKCODE type SYUCOMM .
  methods SET_PUBLISH_TOPIC
    importing
      !IV_TOPIC type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_WIDGET .
  methods SET_CFG_IDX
    importing
      !IV_IDX type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_WIDGET .
  methods SET_FROM_CFG
    importing
      !IS_CONFIG type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_WIDGET .
  methods SET_MIN
    importing
      !IV_MIN type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_WIDGET .
  methods SET_MAX
    importing
      !IV_MAX type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_WIDGET .
  methods SET_CUR
    importing
      !IV_CUR type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_WIDGET .
  methods HANDLE_PAYLOAD
    importing
      !IV_TOPIC type DATA
      !IV_PAYLOAD type DATA
      !IV_UPDATED type ZMQBA_TIMESTAMP optional
    returning
      value(RV_HANDLED) type ABAP_BOOL .
  methods SET_UNIT
    importing
      !IV_UNIT type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_WIDGET .
  methods SET_SUBSCREEN_MODE
    importing
      !IV_CONTAINER type DATA
      !IV_VARIANT type NUMC2 default '00'
    returning
      value(RR_SELF) type ref to ZIF_MQBA_GUI_WIDGET .
  methods IS_SUBSCREEN
    returning
      value(RV_SUBSCREEN) type ABAP_BOOL .
endinterface.
