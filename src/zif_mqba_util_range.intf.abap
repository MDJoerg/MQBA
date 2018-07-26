interface ZIF_MQBA_UTIL_RANGE
  public .


  methods ADD_RSPARAMS
    importing
      !IS_PARAM type RSPARAMS
    returning
      value(RR_SELF) type ref to ZIF_MQBA_UTIL_RANGE .
  methods ADD
    importing
      !IV_DATA type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_UTIL_RANGE .
  methods ADD_INTERVAL
    importing
      !IV_FROM type DATA
      !IV_TO type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_UTIL_RANGE .
  methods CHECK
    importing
      !IV_DATA type DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods ADD_OP
    importing
      !IV_DATA type DATA
      !IV_OPTION type TVARV_OPTI
    returning
      value(RR_SELF) type ref to ZIF_MQBA_UTIL_RANGE .
  methods RESET .
  methods GET_COUNT
    returning
      value(RV_COUNT) type I .
  methods IS_EMPTY
    returning
      value(RV_EMPTY) type ABAP_BOOL .
  methods GET_RANGE
    returning
      value(RT_RANGE) type ZMQBA_RNG_T_STRING .
endinterface.
