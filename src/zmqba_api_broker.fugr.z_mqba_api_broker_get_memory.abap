FUNCTION z_mqba_api_broker_get_memory.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_TOPIC) TYPE  STRING OPTIONAL
*"     VALUE(IV_SENDER) TYPE  STRING OPTIONAL
*"     VALUE(IV_SENDER_REF) TYPE  STRING OPTIONAL
*"     VALUE(IV_CONTEXT) TYPE  STRING OPTIONAL
*"     VALUE(IV_TIME_FROM) TYPE  ZMQBA_TIMESTAMP OPTIONAL
*"  EXPORTING
*"     VALUE(ES_DATA) TYPE  ZMQBA_API_S_BRK_MSG
*"     VALUE(EV_ERROR) TYPE  ZMQBA_FLAG_ERROR
*"----------------------------------------------------------------------

* ------ get messages from memory with parameters
* get broker access
  DATA(lr_broker) = zcl_mqba_factory=>get_broker( ).
* read memory with params
  es_data = lr_broker->get_current_memory(
    iv_filter_context    = iv_context
    iv_filter_topic      = iv_topic
    iv_timestamp_from    = iv_time_from
    iv_filter_sender     = iv_sender
    iv_filter_sender_ref = iv_sender_ref ).

*     sort: newest first
  SORT es_data-msg BY updated DESCENDING.

* fill error flag
  ev_error = COND #( WHEN es_data-error IS INITIAL
                     THEN abap_false
                     ELSE abap_true ).

ENDFUNCTION.
