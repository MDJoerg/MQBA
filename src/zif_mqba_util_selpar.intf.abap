interface ZIF_MQBA_UTIL_SELPAR
  public .


  methods ADD_FROM_PROG_CONTEXT
    importing
      !IT_FIELDS type ZMQBA_GUI_T_SELPAR
      !IV_PROG type DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods ADD_FROM_SELECTION_SCREEN
    importing
      !IV_PROG type DATA
      !IV_DYNNR type DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods FILL_STRUCTURE
    importing
      !IV_WITH_SELOPT type ABAP_BOOL default ABAP_FALSE
      !IV_OVERWRITE type ABAP_BOOL default ABAP_FALSE
    changing
      !CS_STRUC type DATA .
  methods GET_AS_RANGE
    importing
      !IV_PARAM type DATA
    returning
      value(RR_RANGE) type ref to ZIF_MQBA_UTIL_RANGE .
  methods GET_PARAM
    importing
      !IV_PARAM type DATA
    returning
      value(RV_STRING) type STRING .
  methods GET_ALL
    returning
      value(RT_PARAMS) type RSPARAMS_TT .
endinterface.
