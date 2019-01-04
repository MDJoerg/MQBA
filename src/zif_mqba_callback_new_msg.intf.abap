interface ZIF_MQBA_CALLBACK_NEW_MSG
  public .


  methods ON_MESSAGE
    importing
      !IS_MSG type ZMQBA_API_S_EBR_MSG
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
endinterface.
