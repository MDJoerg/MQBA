interface ZIF_MQBA_API_MQTT_PROXY
  public .


  constants C_STATE_NOT_INITIALIZED type STRING value 'notinitialized' ##NO_TEXT.
  constants C_STATE_CONNECTING type STRING value 'connecting' ##NO_TEXT.
  constants C_STATE_CONNECTED type STRING value 'connected' ##NO_TEXT.
  constants C_STATE_DISCONNECTING type STRING value 'disconnecting' ##NO_TEXT.
  constants C_STATE_DISCONNECTED type STRING value 'disconnected' ##NO_TEXT.
  constants C_STATE_UNKNOWN type STRING value 'unknown' ##NO_TEXT.
  constants C_STATE_ERROR type STRING value 'error' ##NO_TEXT.

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
      !IV_TOPIC type DATA
      !IV_USE_PREFIX type ABAP_BOOL default ABAP_TRUE
      !IV_QOS type ZMQBA_MQTT_QOS default 0
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods DESTROY .
  methods SET_CALLBACK_NEW_MSG
    importing
      !IR_CALLBACK type ref to ZIF_MQBA_CALLBACK_NEW_MSG optional
    returning
      value(RR_SELF) type ref to ZIF_MQBA_API_MQTT_PROXY .
  methods PUBLISH
    importing
      !IV_TOPIC type STRING
      !IV_PAYLOAD type STRING
      !IV_QOS type I default 0
      !IV_RETAIN type ABAP_BOOL default ABAP_FALSE
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods GET_CLIENT_ID
    returning
      value(RV_CLIENT_ID) type STRING .
  methods GET_CLIENT_STATE
    returning
      value(RV_STATE) type STRING .
endinterface.
