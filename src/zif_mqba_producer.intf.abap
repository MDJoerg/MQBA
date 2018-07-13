interface ZIF_MQBA_PRODUCER
  public .


  methods SET_TOPIC
    importing
      !IV_TOPIC type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_PRODUCER .
  methods SET_PAYLOAD
    importing
      !IV_PAYLOAD type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_PRODUCER .
  methods SET_CONSUMER_ID
    importing
      !IV_CONSUMER_ID type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_PRODUCER .
  methods SET_EXTERNAL
    returning
      value(RR_SELF) type ref to ZIF_MQBA_PRODUCER .
  methods PUBLISH
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods GET_EXCEPTION
    returning
      value(RR_EXCEPTION) type ref to CX_ROOT .
  methods GET_ERROR_TEXT
    returning
      value(RV_TEXT) type STRING .
  methods IS_FAILED
    returning
      value(RV_FAILED) type ABAP_BOOL .
  methods SET_FIELD
    importing
      !IV_NAME type DATA
      !IV_VALUE type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_PRODUCER .
  methods GET_MESSAGE
    returning
      value(RR_MSG) type ref to ZIF_MQBA_REQUEST .
  methods SET_CONTEXT
    importing
      !IV_CONTEXT type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_PRODUCER .
endinterface.
