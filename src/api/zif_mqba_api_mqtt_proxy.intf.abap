interface ZIF_MQBA_API_MQTT_PROXY
  public .


  methods CONNECT
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods DISCONNECT
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods RECONNECT
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods IS_CONNECTED
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods SET_CONFIG
    importing
      !IR_CFG type ref to ZIF_MQBA_CFG_BROKER
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods GET_ERROR
    returning
      value(RV_ERROR) type I .
  methods GET_ERROR_TEXT
    returning
      value(RV_ERROR) type STRING .
  methods IS_ERROR
    returning
      value(RV_ERROR) type ABAP_BOOL .
endinterface.
