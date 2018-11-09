interface ZIF_MQBA_CFG_BROKER
  public .


  methods SET_ID
    importing
      !IV_ID type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_CFG_BROKER .
  methods GET_ID
    returning
      value(RV_ID) type STRING .
  methods GET_CONFIG
    returning
      value(RS_CONFIG) type ZMQBA_API_S_BRK_CFG .
  methods IS_VALID
    returning
      value(RV_VALID) type STRING .
endinterface.
