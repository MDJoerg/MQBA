interface ZIF_MQBA_SHM_CONTEXT
  public .


  methods PUT_TAB
    importing
      !IV_GROUP type DATA optional
      !IT_PARAM type ZMQBA_MBC_T_DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods PUT
    importing
      !IV_GROUP type DATA optional
      !IV_PARAM type DATA
      !IV_VALUE type DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods REMOVE
    importing
      !IV_GROUP type DATA optional
      !IV_PARAM type DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods CALC_INT
    importing
      !IV_GROUP type DATA optional
      !IV_PARAM type DATA
      !IV_DELTA type I default 1
    returning
      value(RV_INT) type I .
  methods GET_TAB
    importing
      !IV_GROUP type DATA optional
      !IT_PARAM type ZMQBA_T_STRING optional
    returning
      value(RT_PARAM) type ZMQBA_MBC_T_DATA .
  methods GET
    importing
      !IV_GROUP type DATA optional
      !IV_PARAM type DATA
    returning
      value(RV_VALUE) type STRING .
  methods SET_GROUP
    importing
      !IV_GROUP type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_SHM_CONTEXT .
  methods GET_COUNT
    importing
      !IV_GROUP type DATA optional
    returning
      value(RV_COUNT) type I .
  methods GET_NAMES
    importing
      !IV_GROUP type DATA
    returning
      value(RT_NAMES) type ZMQBA_T_STRING .
  methods CLEAR
    importing
      !IV_GROUP type DATA optional
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods GET_GROUPS
    returning
      value(RT_GROUPS) type ZMQBA_T_STRING .
endinterface.
