interface ZIF_MQBA_DAEMON_MGR
  public .


  methods SET_CONFIG
    importing
      !IR_CFG type ref to ZIF_MQBA_CFG_BROKER
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods IS_AVAILABLE
    returning
      value(RV_AVAILABLE) type ABAP_BOOL .
  methods START
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods STOP
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods RESTART
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods PUBLISH
    importing
      !IV_TOPIC type STRING
      !IV_PAYLOAD type STRING
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
endinterface.
