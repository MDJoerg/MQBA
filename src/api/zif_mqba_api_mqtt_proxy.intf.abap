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
  methods SET_CONFIG_APC
    importing
      !IS_APC type APC_CONNECT_OPTIONS
    returning
      value(RR_SELF) type ref to ZIF_MQBA_API_MQTT_PROXY .
  methods SET_CLIENT_ID
    importing
      !IV_CLIENT_ID type DATA
    returning
value(RR_SELF) type ref to ZIF_MQBA_API_MQTT_PROXY .
  methods SET_LAST_WILL
    importing
      !IV_TOPIC type DATA
      !IV_PAYLOAD type DATA
      !IV_QOS type ZMQBA_MQTT_QOS default 0
      !IV_RETAIN type ZMQBA_MQTT_RETAIN default ABAP_FALSE
   returning
      value(RR_SELF) type ref to ZIF_MQBA_API_MQTT_PROXY .
  methods GET_ERROR
    returning
      value(RV_ERROR) type I .
  methods GET_ERROR_TEXT
    returning
      value(RV_ERROR) type STRING .
  methods IS_ERROR
    returning
     value(RV_ERROR) type ABAP_BOOL .
  methods GET_RECEIVED_MESSAGES
    importing
      !IV_DELETE type ABAP_BOOL default ABAP_TRUE
    returning
      value(RT_MSG) type ZMQBA_API_T_EBR_MSG .
  methods SUBSCRIBE_TO
    importing
      !IV_TOPICtype DATA
      !IV_USE_PREFIX type ABAP_BOOL default ABAP_TRUE
      !IV_QOS type ZMQBA_MQTT_QOS default 0
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods DESTROY .
endinterface.
