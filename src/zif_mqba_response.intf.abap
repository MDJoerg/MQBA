interface ZIF_MQBA_RESPONSE
  public .


  methods POST_ANSWER
    importing
      !IV_MSG type STRING
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
endinterface.
