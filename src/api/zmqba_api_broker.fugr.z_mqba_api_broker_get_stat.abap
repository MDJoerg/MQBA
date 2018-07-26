FUNCTION z_mqba_api_broker_get_stat.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(ES_STAT) TYPE  ZMQBA_API_S_BRK_STC
*"     VALUE(EV_ERROR) TYPE  ZMQBA_FLAG_ERROR
*"----------------------------------------------------------------------

* ------ get messages from memory with parameters
* get broker access
  DATA(lr_broker) = zcl_mqba_factory=>get_broker( ).
* read memory with params
  es_stat = lr_broker->get_statistic( ).

* fill error flag
  ev_error = COND #( WHEN es_stat IS NOT INITIAL
                     THEN abap_false
                     ELSE abap_true ).

ENDFUNCTION.
