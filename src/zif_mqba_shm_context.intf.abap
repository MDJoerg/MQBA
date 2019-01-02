interface ZIF_MQBA_SHM_CONTEXT
  public .


  methods PUT
    importing
      !IV_GROUP type DATA optional
      !IV_PARAM type DATA
      !IV_VALUE type DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
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
endinterface.
