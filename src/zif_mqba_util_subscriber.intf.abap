interface ZIF_MQBA_UTIL_SUBSCRIBER
  public .


  methods SET_CONTEXT
    importing
      !IS_CONTEXT type ZMQBA_API_S_BPR_SUB_CALL
    returning
      value(RR_SELF) type ref to ZIF_MQBA_UTIL_SUBSCRIBER .
  methods SET_TOPIC_IN_MASK
    importing
      !IV_TOPIC_MASK type DATA
    returning
      value(RR_SELF) type ref to ZIF_MQBA_UTIL_SUBSCRIBER .
  methods GET_TOPIC_IN_PART
    importing
      !RV_PART type STRING
      !IV_ID type DATA .
  methods IS_ECHO
    importing
      !IV_MSEC type I default 1000
    returning
      value(RV_KNOWN) type ABAP_BOOL .
endinterface.
