interface ZIF_MQBA_GUI_BL
  public .

  types: ty_subscreens type standard table of ref to ZIF_MQBA_GUI_SUBSCREEN with default key.

  methods DESTROY .
  methods GET_PARAMETERS
    returning
      value(RR_PARAMS) type ref to ZIF_MQBA_UTIL_SELPAR .
  methods PAI
    exporting
      !EV_NEXT_DYNNR type SYDYNNR
    changing
      !CV_OKCODE type SYUCOMM
      !CS_UIDATA type DATA .
  methods PBO
    exporting
      !ET_EXCL_FCODES type ZMQBA_T_SYUCOMM
      !EV_TEXT type STRING
      !EV_TITLEBAR type STRING
      !EV_STATUS type STRING
    changing
      !CV_OKCODE type SYUCOMM
      !CS_UIDATA type DATA .
  methods COLLECT_PARAMS
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods GET_SUBSCREENS
    returning
      value(RT_SUBSCREEN) type ty_subscreens .
  methods GET_SUBSCREEN
    importing
      !IV_CONTAINER type DATA
    returning
      value(RR_SUBSCREEN) type ref to ZIF_MQBA_GUI_SUBSCREEN .
endinterface.
