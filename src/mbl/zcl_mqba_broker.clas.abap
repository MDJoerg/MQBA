class ZCL_MQBA_BROKER definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_BROKER .
protected section.

  data M_EXCEPTION type ref to CX_ROOT .
  data M_SHM_CONFIG type ZMQBA_SHM_S_PMG_OUT .

  methods DISTRIBUTE_EXTERNAL
    importing
      !IR_MSG type ref to ZIF_MQBA_REQUEST
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods DISTRIBUTE_SUBSCRIBERS
    importing
      !IR_MSG type ref to ZIF_MQBA_REQUEST
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods CREATE_EXCEPTION
    importing
      !IV_TEXT type DATA .
  methods CHECK_BAW_LIST_EXT_MSG
    importing
      !IR_MSG type ref to ZIF_MQBA_REQUEST
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods PUT_TO_STORAGE
    importing
      !IR_MSG type ref to ZIF_MQBA_REQUEST
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods RESET .
  methods SEND_GATEWAY_MESSAGE
    importing
      !IR_MSG type ref to ZIF_MQBA_REQUEST
      !IV_GATEWAY_ID type DATA optional
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods SEND_PCP_MESSAGE
    importing
      !IR_MSG type ref to ZIF_MQBA_REQUEST
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
private section.
ENDCLASS.



CLASS ZCL_MQBA_BROKER IMPLEMENTATION.


  METHOD check_baw_list_ext_msg.

* ---- initialize some vars
    rv_success = abap_false.


* ---- testing issues
    BREAK-POINT ID zmqba_shm.

    LOG-POINT ID zmqba_shm SUBKEY 'check_ext_msg_valid'
      FIELDS ir_msg->get_guid( )
             ir_msg->get_id( )
             ir_msg->get_sender( )
             ir_msg->get_context( )
             ir_msg->get_topic( ).


* ---- check topic is given
    CHECK ir_msg IS NOT INITIAL
      AND ir_msg->get_topic( ) IS NOT INITIAL.


* ---- try to store the current message to shared memory
    DO 1000 TIMES.
      TRY.
*   store new event to shared memory
*       reset m_exception
          CLEAR m_exception.
*       get area access
          DATA(lr_area) = zcl_mqba_shm_area=>attach_for_read( ).
*       call root handler
          rv_success = lr_area->root->check_valid_msg_gwi( ir_msg->get_topic( ) ).
*       release access
          lr_area->detach( ).
*       exit from do
          EXIT.
*       catch errors
        CATCH cx_shm_read_lock_active
              cx_shm_no_active_version
              cx_shm_inconsistent
              cx_shm_exclusive_lock_active
              cx_shm_change_lock_active
              INTO m_exception.
          LOG-POINT ID zmqba_shm
             SUBKEY 'check_ext_msg_valid_failed'
             FIELDS sy-index m_exception->get_text( ).
      ENDTRY.
    ENDDO.

* ----- error handling
    rv_success = COND #( WHEN m_exception IS BOUND
                         THEN abap_false
                         ELSE abap_true ).

    ASSERT ID zmqba_shm SUBKEY 'check_ext_msg_valid_failed'
      FIELDS rv_success
      CONDITION rv_success EQ abap_true.


  ENDMETHOD.


  METHOD create_exception.
    m_exception = zcl_mqba_factory=>create_exception( iv_text ).
  ENDMETHOD.


  METHOD distribute_external.

* ------ first check scope -> D
    IF ir_msg->get_scope( ) NE zif_mqba_broker=>c_scope_distributed.
*   nothing to do
      rv_success = abap_true.
      EXIT.
    ENDIF.


* ------ at the moment only distribution to apc channel exists...
* TODO: routing, differend gateway methods and private messaging are planned
    rv_success = send_gateway_message( ir_msg ).

  ENDMETHOD.


  METHOD distribute_subscribers.

* ------- local data
    DATA: lv_error TYPE abap_bool.
    DATA: lv_qname TYPE trfcqnam.

    DATA: ls_msg      TYPE  zmqba_msg_s_main.
    DATA: ls_cfg_msg  TYPE  zmqba_shm_s_cfg_msg.
    DATA: ls_cfg_sub  TYPE  zmqba_shm_s_cfg_sub.

* ------- check
    rv_success = abap_true.
    CHECK m_shm_config IS NOT INITIAL
      AND m_shm_config-subscribers[] IS NOT INITIAL.

* ------- prepare loop
    lv_qname = 'ZMQBA-SUB'.




* ------- loop all subscribers and process
    LOOP AT m_shm_config-subscribers INTO DATA(ls_sub_scfg).

* prepare data
      MOVE-CORRESPONDING m_shm_config-msg_data   TO ls_msg.
      MOVE-CORRESPONDING m_shm_config-msg_config TO ls_cfg_msg.
      MOVE-CORRESPONDING ls_sub_scfg             TO ls_cfg_sub.

* open luw
      SET UPDATE TASK LOCAL.

* set qname
      CALL FUNCTION 'TRFC_SET_QIN_PROPERTIES'
        EXPORTING
*         QOUT_NAME          = ' '
          qin_name           = lv_qname
*         QIN_COUNT          =
*         CALL_EVENT         = ' '
*         NO_EXECUTE         = ' '
        EXCEPTIONS
          invalid_queue_name = 1
          OTHERS             = 2.
      IF sy-subrc <> 0.
        lv_error = abap_true.
      ENDIF.

* call background processing
      CALL FUNCTION 'Z_MQBA_MBL_BPR_CALL_SUBSCRIBER'
        IN BACKGROUND TASK AS SEPARATE UNIT
        DESTINATION 'NONE'
        EXPORTING
          is_msg     = ls_msg
          is_cfg_msg = ls_cfg_msg
          is_cfg_sub = ls_cfg_sub.

* finish
      COMMIT WORK.

    ENDLOOP.



* final result
    rv_success = COND #( WHEN lv_error EQ abap_true
                         THEN abap_false
                         ELSE abap_true ).

  ENDMETHOD.


  METHOD put_to_storage.

* ---- initialize some vars
    CLEAR m_shm_config.
    rv_success = abap_true.


* ---- testing issues
    BREAK-POINT ID zmqba_shm.

    LOG-POINT ID zmqba_shm SUBKEY 'put_to_storage'
      FIELDS ir_msg->get_guid( )
             ir_msg->get_id( )
             ir_msg->get_sender( )
             ir_msg->get_context( )
             ir_msg->get_topic( ).


* ---- check exceptions occured before
    IF m_exception IS BOUND.
      CLEAR rv_success.
    ENDIF.

    ASSERT ID zmqba_shm SUBKEY 'put_with_exc'
      FIELDS rv_success
      CONDITION rv_success EQ abap_true.

    CHECK rv_success EQ abap_true.




* ---- try to store the current message to shared memory
    DO 1000 TIMES.
      TRY.
*   store new event to shared memory
*       reset m_exception
          CLEAR m_exception.
*       get area access
          DATA(lr_area) = zcl_mqba_shm_area=>attach_for_update( ).
*       call root handler
          m_shm_config = lr_area->root->message_put( ir_msg ).
*       release access
          lr_area->detach_commit( ).
*       exit from do
          EXIT.
*       catch errors
        CATCH cx_shm_inconsistent
              cx_shm_no_active_version
              cx_shm_exclusive_lock_active
              cx_shm_version_limit_exceeded
              cx_shm_change_lock_active
              cx_shm_parameter_error
              cx_shm_pending_lock_removed
              INTO m_exception.
          LOG-POINT ID zmqba_shm
             SUBKEY 'put_to_storage_failed'
             FIELDS sy-index m_exception->get_text( ).
      ENDTRY.
    ENDDO.

* ----- error handling
    rv_success = COND #( WHEN m_exception IS BOUND
                         THEN abap_false
                         ELSE abap_true ).

    ASSERT ID zmqba_shm SUBKEY 'put_failed'
      FIELDS rv_success
      CONDITION rv_success EQ abap_true.


  ENDMETHOD.


  METHOD reset.
    CLEAR: m_exception,
           m_shm_config.
  ENDMETHOD.


  METHOD send_gateway_message.

* ----- init and check
    IF ir_msg->get_scope( ) NE zif_mqba_broker=>c_scope_distributed.
      rv_success = abap_true.
      EXIT.
    ENDIF.


* -------- create and send message via AMC PCP
    TRY.
*       create apc text message via apc message api
        DATA(lr_msg) = zcl_mqba_apc_factory=>create_message( ).
        lr_msg->set_data_from_if( ir_msg = ir_msg iv_new_guid = abap_false ).
        DATA(lv_text) = lr_msg->create_outbound_text_message( ).

*       call amc api...
*         create private messahe
*            CAST if_amc_message_producer_pcp(
*                 cl_amc_channel_manager=>create_message_producer_by_id(
*                   i_consumer_session_id = lv_consumer_id
*                   i_communication_type  =
*                       cl_amc_channel_manager=>co_comm_type_synchronous
*                   i_application_id = zif_mqba_broker=>c_int_amc_app
*                   i_channel_id     = zif_mqba_broker=>c_int_amc_chn_messages )
*              )->send( i_message = lr_pcp_msg ).
**         ... without consumer
        CAST if_amc_message_producer_text(
              cl_amc_channel_manager=>create_message_producer(
                i_application_id = zif_mqba_broker=>c_gw_amc_app
                i_channel_id     = zif_mqba_broker=>c_gw_amc_chn_messages )
          )->send( i_message = lv_text ).
*     catch errors
      CATCH cx_amc_error
            cx_ac_message_type_pcp_error
            INTO m_exception.
    ENDTRY.


* ------- error handling
    rv_success = COND #( WHEN m_exception IS BOUND
                         THEN abap_false
                         ELSE abap_true ).



  ENDMETHOD.


  METHOD send_pcp_message.

* ----- local data
    DATA: lr_msg TYPE REF TO zcl_mqba_int_message.



* ----- init and check
    reset( ).
    CLEAR rv_success.
    IF   ir_msg IS INITIAL
      OR ir_msg->get_topic( ) IS INITIAL
      OR ir_msg->get_scope( ) IS INITIAL.
      create_exception( 'invalid message' ).
      EXIT.
    ENDIF.


* -------- create and send message via AMC PCP
    TRY.
*       create pcp message via internal message api
        lr_msg ?= zcl_mqba_factory=>create_message( ).
        lr_msg->set_data_from_if( ir_msg = ir_msg iv_new_guid = abap_false ).
        DATA(lr_pcp_msg) = lr_msg->create_pcp_message( ).

*       call amc api...
        IF ir_msg->get_scope( ) EQ zif_mqba_broker=>c_scope_private.
*         ... with consumer
*         check id
          DATA(lv_consumer_id) = ir_msg->get_property( zif_mqba_broker=>c_int_field_prefix && zif_mqba_broker=>c_int_field_consumer_id ).
          IF lv_consumer_id IS INITIAL.
            create_exception( 'missing consumer id for private messaging' ).
            EXIT.
          ENDIF.
*         create private messahe
          CAST if_amc_message_producer_pcp(
               cl_amc_channel_manager=>create_message_producer_by_id(
                 i_consumer_session_id = lv_consumer_id
                 i_communication_type  =
                     cl_amc_channel_manager=>co_comm_type_synchronous
                 i_application_id = zif_mqba_broker=>c_int_amc_app
                 i_channel_id     = zif_mqba_broker=>c_int_amc_chn_messages )
            )->send( i_message = lr_pcp_msg ).
        ELSE.
*         ... without consumer
          CAST if_amc_message_producer_pcp(
                cl_amc_channel_manager=>create_message_producer(
                  i_application_id = zif_mqba_broker=>c_int_amc_app
                  i_channel_id     = zif_mqba_broker=>c_int_amc_chn_messages )
            )->send( i_message = lr_pcp_msg ).
        ENDIF.
*     catch errors
      CATCH cx_amc_error
            cx_ac_message_type_pcp_error
            INTO m_exception.
    ENDTRY.


* ------- error handling
    rv_success = COND #( WHEN m_exception IS BOUND
                         THEN abap_false
                         ELSE abap_true ).



  ENDMETHOD.


  METHOD zif_mqba_broker~external_message_arrived.


* ------ set default
    reset( ).
    CLEAR rv_success.

* ------ check against black and whitelist
    CHECK check_baw_list_ext_msg( ir_msg ) EQ abap_true.

* ------ store to memory and get configuration
    CHECK put_to_storage( ir_msg ) EQ abap_true.

* ------ call amc channel
    CHECK send_pcp_message( ir_msg ) EQ abap_true.

* ----- trigger subscribers
    CHECK distribute_subscribers( ir_msg ) EQ abap_true.

* ------ result
    rv_success = abap_true.

  ENDMETHOD.


  METHOD zif_mqba_broker~get_current_memory.

* ------ local data
    DATA: ls_params TYPE zmqba_api_s_brk_msg_in.
    DATA: lv_max_try TYPE i VALUE 5.

* ------ build api in structure
    ls_params-topic       = iv_filter_topic.
    ls_params-context     = iv_filter_context.
    ls_params-sender      = iv_filter_sender.
    ls_params-sender_ref  = iv_filter_sender_ref.
    ls_params-ts_from     = iv_timestamp_from.

* ---- try to store the current message to shared memory
*    prepare retry
    DATA(lv_try) = 0.

*    start loop
    DO.
      TRY.
*       reset
          reset( ).
*       get area access
          DATA(lr_area) = zcl_mqba_shm_area=>attach_for_read( ).
*       call root handler
          rs_result = lr_area->root->read_msg_memory( ls_params ).
*       release access
          lr_area->detach( ).
*       exit from to
          EXIT.
* ----- catch errors
        CATCH cx_shm_inconsistent
              cx_shm_read_lock_active
              cx_shm_no_active_version
              cx_shm_exclusive_lock_active
              cx_shm_change_lock_active
              INTO m_exception.
*       store the message
          rs_result-error = m_exception->get_text( ).
*       retry?
          ADD 1 TO lv_try.

          LOG-POINT ID zmqba_shm SUBKEY 'retry_get_cur_mem' FIELDS lv_try lv_max_try.

          ASSERT ID zmqba_shm SUBKEY 'get_cur_mem_failed' CONDITION lv_try LE lv_max_try.

*         retry wanted?
          IF lv_try LE lv_max_try.
            WAIT UP TO 1 SECONDS.
          ELSE.
            LOG-POINT ID zmqba_shm SUBKEY 'get_cur_mem_failed' FIELDS lv_try.
          ENDIF.
      ENDTRY.
    ENDDO.

  ENDMETHOD.


  METHOD zif_mqba_broker~get_exception.
    rr_exception ?= m_exception.
  ENDMETHOD.


  METHOD zif_mqba_broker~get_last_error.
    CHECK m_exception IS NOT INITIAL.
    rv_error_msg = m_exception->get_text( ).
  ENDMETHOD.


  method ZIF_MQBA_BROKER~GET_STATISTIC.

    DO 1000 times.
      TRY.
*       reset
          reset( ).
*       get area access
          DATA(lr_area) = zcl_mqba_shm_area=>attach_for_read( ).
*       call root handler
          rs_stat = lr_area->root->statistic_get( ).
*       release access
          lr_area->detach( ).
*       exit from to
          EXIT.
* ----- catch errors
        CATCH cx_shm_inconsistent
              cx_shm_read_lock_active
              cx_shm_no_active_version
              cx_shm_exclusive_lock_active
              cx_shm_change_lock_active
              INTO m_exception.
*       store the message
          "rs_result-error = m_exception->get_text( ).
      ENDTRY.
    ENDDO.

  endmethod.


  METHOD zif_mqba_broker~internal_message_arrived.

* ----- initial checks
    reset( ).
    CLEAR rv_success.

* ----- first send to amc channel (private/internal messages)
    CHECK send_pcp_message( ir_msg ) EQ abap_true.


* ----- store message to storage and get configuration (except private messages)
    CHECK put_to_storage( ir_msg ) EQ abap_true.


* ----- start external distribution
    CHECK distribute_external( ir_msg ) EQ abap_true.


* ----- trigger subscribers
    CHECK distribute_subscribers( ir_msg ) EQ abap_true.


* ----- finally success
    rv_success = abap_true.

  ENDMETHOD.
ENDCLASS.
