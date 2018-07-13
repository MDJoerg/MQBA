interface ZIF_MQBA_CONSUMER
  public .


  methods SET_CONTEXT_FILTER
    importing
      !IV_CTX_FILTER type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_CONSUMER .
  methods SUBSCRIBE
    importing
      !IV_TOPIC type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_CONSUMER .
  methods WAIT_FOR_MESSAGES
    importing
      !IV_WAIT_UP_TO_SEC type I
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods GET_CONSUMER_ID
    returning
      value(RV_CONSUMER_ID) type STRING .
  methods GET_EXCEPTION
    returning
      value(RR_EXCEPTION) type ref to CX_ROOT .
  methods GET_ERROR_TEXT
    returning
      value(RV_ERR_TEXT) type STRING .
  methods GET_MESSAGE_PCP
    returning
      value(RR_PCP_MSG) type ref to IF_AC_MESSAGE_TYPE_PCP .
  methods GET_MESSAGE
    returning
      value(RR_MSG) type ref to ZIF_MQBA_REQUEST .
endinterface.
