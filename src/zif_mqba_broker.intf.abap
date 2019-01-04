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
  constants C_PARAM_HISTORY_ENABLED_NAME type STRING value 'broker.history.enabled' ##NO_TEXT.
  constants C_PARAM_HISTORY_ENABLED_DEF type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  constants C_PARAM_HISTORY_MAX_NAME type STRING value 'broker.history.max' ##NO_TEXT.
  constants C_PARAM_HISTORY_MAX_DEF type I value 5 ##NO_TEXT.
  constants C_PARAM_HISTORY_QUEUE_NAME type STRING value 'broker.history.queue' ##NO_TEXT.
  constants C_PARAM_HISTORY_QUEUE_DEF type STRING value 'ZMQBA-HIST' ##NO_TEXT.
  constants C_PARAM_HISTORY_BPRMOD_NAME type STRING value 'broker.history.module' ##NO_TEXT.
  constants C_PARAM_HISTORY_BPRMOD_DEF type STRING value 'Z_MQBA_MBL_BPR_SAVE_HISTORY' ##NO_TEXT.
  constants C_PARAM_HISTORY_RFCDEST_NAME type STRING value 'broker.history.destination' ##NO_TEXT.
  constants C_PARAM_HISTORY_RFCDEST_DEF type STRING value 'NONE' ##NO_TEXT.
  constants C_PARAM_MESSAGE_EXPIRE_NAME type STRING value 'broker.message.expiration' ##NO_TEXT.
  constants C_PARAM_MESSAGE_EXPIRE_DEF type STRING value 300 ##NO_TEXT.
  constants C_PARAM_CLEANUP_INTERVAL_NAME type STRING value 'broker.message.cleanup' ##NO_TEXT.
  constants C_PARAM_CLEANUP_INTERVAL_DEF type STRING value 300 ##NO_TEXT.
  constants C_PARAM_SUBSCRIBE_QUEUE_NAME type STRING value 'broker.subscriber.queue' ##NO_TEXT.
  constants C_PARAM_SUBSCRIBE_QUEUE_DEF type STRING value 'ZMQBA-SUB' ##NO_TEXT.
  constants C_PARAM_SUBSCRIBE_RFCDEST_NAME type STRING value 'broker.history.destination' ##NO_TEXT.
  constants C_PARAM_SUBSCRIBE_RFCDEST_DEF type STRING value 'NONE' ##NO_TEXT.
  constants C_PARAM_SUBSCRIBE_BPRMOD_NAME type STRING value 'broker.history.module' ##NO_TEXT.
  constants C_PARAM_SUBSCRIBE_BPRMOD_DEF type STRING value 'Z_MQBA_MBL_BPR_CALL_SUBSCRIBER' ##NO_TEXT.
  constants C_PARAM_GATEWAY_NAME type STRING value 'broker.gateway.default' ##NO_TEXT.
  constants C_PARAM_GATEWAY_DEF type STRING value 'LOCAL' ##NO_TEXT.

  methods EXTERNAL_MESSAGE_PUBLISH
    importing
      !IV_TOPIC type STRING
      !IV_PAYLOAD type STRING
      !IV_BROKER_ID type ZMQBA_BROKER_ID optional
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
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
  methods EXTERNAL_MESSAGES_ARRIVED
    importing
      !IS_PARAMS type ZMQBA_API_S_EBR_MSG_IN
    returning
      value(RS_RESULT) type ZMQBA_API_S_EBR_MSG_OUT .
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
  methods GET_STATISTIC
    returning
      value(RS_STAT) type ZMQBA_API_S_BRK_STC .
endinterface.
