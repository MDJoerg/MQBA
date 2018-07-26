interface ZIF_MQBA_GUI_UTIL
  public .


  methods GET_DYNPRO_PARAMS
    importing
      !IV_PROG type DATA
      !IV_DYNNR type SYDYNNR
    returning
      value(RT_FIELDS) type ZMQBA_GUI_T_SELPAR .
endinterface.
