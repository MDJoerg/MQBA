interface ZIF_MQBA_GUI_SUBSCREEN
  public .


  methods GET_SCREEN
    exporting
      value(EV_PROGRAM) type PROGRAM
      value(EV_DYNNR) type SYDYNNR .
  methods PBX_BEFORE .
  methods PBO
    changing
      !CS_UIDATA type DATA .
  methods PAI
    changing
      !CS_UIDATA type DATA
      !CV_UCOMM type SYUCOMM .
  methods GET_CONTAINER
    returning
      value(RV_CONTAINER) type STRING .
endinterface.
