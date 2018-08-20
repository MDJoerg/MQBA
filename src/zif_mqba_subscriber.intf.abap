interface ZIF_MQBA_SUBSCRIBER
  public .


  methods PROCESS
    importing
      !IS_CONTEXT type ZMQBA_API_S_BPR_SUB_CALL
    returning
      value(RV_MSG_TYPE) type BAPI_MTYPE .
endinterface.
