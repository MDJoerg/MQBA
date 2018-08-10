interface ZIF_MQBA_UTIL_QRFC
  public .


  methods BUILD_QUEUE_NAME
    importing
      !IV_PREFIX type ANY optional
      !IV_NAME type ANY
      !IV_POSTFIX type ANY optional
    returning
      value(EV_NAME) type TRFCQNAM .
  methods DESTROY .
  methods GET_QIN_SIZE
    importing
      !IV_QUEUE type ANY
    returning
      value(EV_SIZE) type I .
  methods GET_QIN_STATUS
    importing
      !IV_QUEUE type ANY
    returning
      value(EV_STATUS) type QRFCSTATE .
  methods GET_QOUT_SIZE
    importing
      !IV_QUEUE type ANY
      !IV_DEST type ANY default '*'
    returning
      value(EV_SIZE) type ABAP_BOOL .
  methods GET_QOUT_STATUS
    importing
      !IV_QUEUE type ANY
      !IV_DEST type ANY default '*'
    returning
      value(EV_STATUS) type QRFCSTATE .
  methods GET_TRANSACTION_ID
    returning
      value(EV_ID) type STRING .
  methods IS_QIN_EXISTS
    importing
      !IV_QUEUE type ANY
    returning
      value(EV_EXISTS) type ABAP_BOOL .
  methods IS_QOUT_EXISTS
    importing
      !IV_QUEUE type ANY
      !IV_DEST type ANY default '*'
    returning
      value(EV_EXISTS) type ABAP_BOOL .
  methods SET_QRFC_INBOUND
    importing
      !IV_QUEUE type ANY
      !IV_START_TRANSACTION type ABAP_BOOL default ABAP_TRUE
    returning
      value(EV_SUCCESS) type ABAP_BOOL .
  methods SET_QRFC_OUTBOUND
    importing
      !IV_QUEUE type ANY
      !IV_START_TRANSACTION type ABAP_BOOL default ABAP_TRUE
    returning
      value(EV_SUCCESS) type ABAP_BOOL .
  methods SET_QUEUE
    importing
      !IV_INBOUND type ABAP_BOOL default ABAP_FALSE
      !IV_QUEUE type ANY
    returning
      value(EV_SUCCESS) type ABAP_BOOL .
  methods SET_STATUS_RETRY_LATER
    returning
      value(EV_SUCCESS) type ABAP_BOOL .
  methods TRANSACTION_BEGIN .
  methods TRANSACTION_CANCEL .
  methods TRANSACTION_END
    importing
      !IV_WAIT type ABAP_BOOL default ABAP_FALSE .
  methods GET_RFC_DEST_FROM_LOGSYS
    importing
      !IV_LOGSYS type DATA
    returning
      value(RV_RFCDEST) type RFCDEST .
endinterface.
