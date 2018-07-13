interface ZIF_MQBA_BROKER
  public .


  constants C_GW_AMC_APP type AMC_APPLICATION_ID value 'ZMQBA_GW' ##NO_TEXT.
  constants C_GW_AMC_CHN_MESSAGES type AMC_CHANNEL_ID value '/outbound' ##NO_TEXT.
  constants C_INT_AMC_APP type AMC_APPLICATION_ID value 'ZMQBA_INT' ##NO_TEXT.
  constants C_INT_AMC_CHN_MESSAGES type AMC_CHANNEL_ID value '/messages' ##NO_TEXT.
  constants C_INT_FIELD_SCOPE type STRING value 'scope' ##NO_TEXT.
  constants C_INT_FIELD_PREFIX type STRING value 'mqba-' ##NO_TEXT.
  constants C_INT_FIELD_TOPIC type STRING value 'topic' ##NO_TEXT.
  constants C_INT_FIELD_MSGGUID type STRING value 'msg_guid' ##NO_TEXT.
  constants C_INT_FIELD_CONSUMER_ID type STRING value 'consumerid' ##NO_TEXT.
  constants C_INT_FIELD_CONTEXT type STRING value 'context' ##NO_TEXT.
  constants C_INT_FIELD_SENDER type STRING value 'sender' ##NO_TEXT.
  constants C_INT_FIELD_REF type STRING value 'sender_ref' ##NO_TEXT.
  constants C_SCOPE_PRIVATE type ZMQBA_MSG_SCOPE value 'P' ##NO_TEXT.
  constants C_SCOPE_INTERNAL type ZMQBA_MSG_SCOPE value 'I' ##NO_TEXT.
  constants C_SCOPE_DISTRIBUTED type ZMQBA_MSG_SCOPE value 'D' ##NO_TEXT.
  constants C_SCOPE_EXTERNAL type ZMQBA_MSG_SCOPE value 'E' ##NO_TEXT.
  constants C_SCOPE_UNKNOWN type ZMQBA_MSG_SCOPE value ' ' ##NO_TEXT.
  constants C_CHAR_NEWLINE type ABAP_CHAR1 value %_NEWLINE ##NO_TEXT.

  methods GET_EXCEPTION
    returning
      value(RR_EXCEPTION) type ref to CX_ROOT .
  methods GET_LAST_ERROR
    returning
      value(RV_ERROR_MSG) type STRING .
  methods EXTERNAL_MESSAGE_ARRIVED
    importing
      !IR_MSG type ref to ZIF_MQBA_REQUEST
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods INTERNAL_MESSAGE_ARRIVED
    importing
      !IR_MSG type ref to ZIF_MQBA_REQUEST
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods GET_CURRENT_MEMORY
    importing
      !IV_FILTER_CONTEXT type DATA optional
      !IV_FILTER_TOPIC type DATA optional
      !IV_TIMESTAMP_FROM type ZMQBA_TIMESTAMP optional
      !IV_FILTER_SENDER type DATA optional
      !IV_FILTER_SENDER_REF type DATA optional
    returning
      value(RS_RESULT) type ZMQBA_API_S_BRK_MSG .
endinterface.
