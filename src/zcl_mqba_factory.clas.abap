class ZCL_MQBA_FACTORY definition
  public
  create public .

public section.

  class-methods GET_BROKER_CONFIG
    importing
      !IV_BROKER_ID type ZMQBA_BROKER_ID
    returning
      value(RR_BROKER_CFG) type ref to ZIF_MQBA_CFG_BROKER .
  class-methods CREATE_TOPIC_FILTER_CONFIG
    importing
      !IV_BASE_TAB type TABNAME
    returning
      value(RR_INSTANCE) type ref to ZIF_MQBA_CFG_TOPIC_FILTER .
  class-methods CREATE_UTIL_QRFC
    returning
      value(RR_UTIL) type ref to ZIF_MQBA_UTIL_QRFC .
  class-methods CREATE_UTIL_SELPAR
    returning
      value(RR_UTIL) type ref to ZIF_MQBA_UTIL_SELPAR .
  class-methods GET_MY_LOGSYS
    returning
      value(RV_LOGSYS) type LOGSYS .
  class-methods GET_NOW
    returning
      value(RV_TIMESTAMP) type ZMQBA_TIMESTAMP .
  class-methods CREATE_EXCEPTION
    importing
      !IV_TEXT type DATA
    returning
      value(RR_EXCEPTION) type ref to ZCX_MQBA_EXCEPTION .
  class-methods CREATE_MESSAGE
    returning
      value(RR_MESSAGE) type ref to ZCL_MQBA_INT_MESSAGE .
  class-methods CREATE_MSG_GUID
    returning
      value(RV_GUID) type ZMQBA_MSG_GUID .
  class-methods CREATE_UTIL_RANGE
    returning
      value(RR_UTIL) type ref to ZIF_MQBA_UTIL_RANGE .
  class-methods GET_CONSUMER
    returning
      value(RR_CONSUMER) type ref to ZIF_MQBA_CONSUMER .
  class-methods GET_PRODUCER
    returning
      value(RR_PRODUCER) type ref to ZIF_MQBA_PRODUCER .
  class-methods GET_UTIL
    returning
      value(RR_UTIL) type ref to ZIF_MQBA_UTIL .
  class-methods GET_BROKER
    importing
      !IV_CONTEXT type STRING optional
    returning
      value(RR_BROKER) type ref to ZIF_MQBA_BROKER .
  class-methods GET_BASE_DATE
    returning
      value(RV_DATE) type DATUM .
protected section.

  class-data M_BASE_DATE type DATUM .
private section.
ENDCLASS.



CLASS ZCL_MQBA_FACTORY IMPLEMENTATION.


  METHOD create_exception.
    TRY.
        zcx_mqba_exception=>raise( iv_text ).
      CATCH zcx_mqba_exception INTO rr_exception.
    ENDTRY.
  ENDMETHOD.


  METHOD create_message.
    rr_message ?= zcl_mqba_message=>create( 'ZCL_MQBA_INT_MESSAGE' ).
  ENDMETHOD.


  METHOD create_msg_guid.
    rv_guid = cl_uuid_factory=>create_system_uuid( )->create_uuid_c22( ).
  ENDMETHOD.


  METHOD create_topic_filter_config.
    rr_instance = NEW zcl_mqba_cfg_topic_filter( iv_base_tab ).
  ENDMETHOD.


  METHOD create_util_qrfc.
    rr_util = zcl_mqba_util_qrfc=>create( ).
  ENDMETHOD.


  METHOD create_util_range.
    rr_util = NEW zcl_mqba_util_range( ).
  ENDMETHOD.


  METHOD create_util_selpar.
    rr_util = zcl_mqba_util_selpar=>create( ).
  ENDMETHOD.


  METHOD get_base_date.
* possible test injection, set base date externally as a friend
    rv_date = COND #( WHEN m_base_date IS INITIAL
                      THEN sy-datum
                      ELSE m_base_date ).
  ENDMETHOD.


  METHOD get_broker.

    DATA(lr_instance) = NEW zcl_mqba_broker( ).

    rr_broker = lr_instance.

  ENDMETHOD.


  METHOD get_broker_config.
* ------- init
    rr_broker_cfg = NEW zcl_mqba_cfg_broker( ).
    rr_broker_cfg->set_id( iv_broker_id ).
* ------- read cust to cache
    DATA(ls_cfg) = rr_broker_cfg->get_config( ).
* ------- check valid?
    IF rr_broker_cfg->is_valid( ) EQ abap_false.
      CLEAR rr_broker_cfg.
    ENDIF.
  ENDMETHOD.


  METHOD get_consumer.
    rr_consumer = NEW zcl_mqba_consumer( ).
  ENDMETHOD.


  METHOD get_my_logsys.
    " TODO: get it from config params
    rv_logsys = |{ sy-sysid }CLNT{ sy-mandt }|.
  ENDMETHOD.


  METHOD get_now.
    GET TIME STAMP FIELD rv_timestamp.
  ENDMETHOD.


  method GET_PRODUCER.
    rr_producer = new ZCL_MQBA_PRODUCER( ).
  endmethod.


  METHOD get_util.
    rr_util = NEW zcl_mqba_util( ).
  ENDMETHOD.
ENDCLASS.
