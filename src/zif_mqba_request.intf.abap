interface ZIF_MQBA_REQUEST
  public .


  methods GET_TOPIC
    returning
      value(RV_TOPIC) type STRING .
  methods GET_PAYLOAD
    returning
      value(RV_PAYLOAD) type STRING .
  methods GET_ID
    returning
      value(RV_ID) type STRING .
  methods GET_GUID
    returning
      value(RV_GUID) type ZMQBA_MSG_GUID .
  methods GET_SENDER
    returning
      value(RV_SENDER) type STRING .
  methods GET_CONTEXT
    returning
      value(RV_CONTEXT) type STRING .
  methods GET_SCOPE
    returning
      value(RV_SCOPE) type ZMQBA_MSG_SCOPE .
  methods GET_PROPERTY
    importing
      !IV_NAME type STRING
    returning
      value(RV_VALUE) type STRING .
  methods GET_PROPERTIES
    returning
      value(RT_PRP_NAMES) type ZMQBA_T_STRING .
  methods IS_VALID
    returning
      value(RV_VALID) type ABAP_BOOL .
  methods GET_MSG_CONTEXT
    returning
      value(RR_CONTEXT) type ref to ZIF_MQBA_CONTEXT .
  methods GET_MSG_RESPONSE
    returning
      value(RR_RESPONSE) type ref to ZIF_MQBA_RESPONSE .
  methods GET_TIMESTAMP
    returning
      value(RV_TIMESTAMP) type ZMQBA_TIMESTAMP .
endinterface.
