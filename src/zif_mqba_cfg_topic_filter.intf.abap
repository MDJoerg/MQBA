interface ZIF_MQBA_CFG_TOPIC_FILTER
  public .


  methods GET_RANGE
    returning
      value(RR_RANGE) type ref to ZIF_MQBA_UTIL_RANGE .
  methods GET_CONFIG_TABLE
    returning
      value(RT_CFG) type ZMQBA_TBF_T_CFG .
  methods GET_CONFIG_FOR_TOPIC
    importing
      !IV_TOPIC type DATA
    returning
      value(RS_CONFIG) type ZMQBA_TBF_S_CFG .
  methods IS_CONFIGURED
    importing
      !IV_TOPIC type DATA
    returning
      value(RV_CONFIGURED) type ABAP_BOOL .
endinterface.
