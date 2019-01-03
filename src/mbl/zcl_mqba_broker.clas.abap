class ZCL_MQBA_BROKER definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_BROKER .
protected section.

  data M_EXCEPTION type ref to CX_ROOT .
  data M_SHM_CONFIG type ZMQBA_SHM_S_PMG_OUT .
  data M_SHM_RETRY type I value 5000 ##NO_TEXT.

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
  methods GET_MEMORY_PARAM
    importing
      !IV_NAME type DATA
      !IV_DEF type DATA
    returning
      value(RV_VALUE) type STRING .
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
  methods RESET
    importing
      !IV_FULL type ABAP_BOOL default ABAP_FALSE .
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
* get the broker id from message
    DATA(lv_gateway) = ir_msg->get_gateway( ).

* set default gateway from config
    IF lv_gateway IS INITIAL.
      READ TABLE m_shm_config-brk_cfg
         ASSIGNING FIELD-SYMBOL(<lfs_cfg>)
         WITH KEY param_name = zif_mqba_broker=>c_param_gateway_name.
      IF sy-subrc EQ 0 AND <lfs_cfg> IS ASSIGNED.
        lv_gateway = <lfs_cfg>-param_value.
      ELSE.
        lv_gateway = zif_mqba_broker=>c_param_gateway_def.
      ENDIF.
    ENDIF.


* call real external gateway or post it to default apc based service
    IF lv_gateway IS INITIAL
      OR lv_gateway EQ 'LOCAL'.
      rv_success = send_gateway_message( ir_msg ).
    ELSE.
      rv_success = zif_mqba_broker~external_message_publish(
           iv_topic       = ir_msg->get_topic( )
           iv_payload     = ir_msg->get_payload( )
           iv_broker_id   = CONV zmqba_broker_id( lv_gateway )
        ).
    ENDIF.

  ENDMETHOD.


  METHOD distribute_subscribers.

* ------- local data
    DATA: lv_error    TYPE abap_bool.
    DATA: lv_qprefix  TYPE trfcqnam.
    DATA: lv_qname    TYPE trfcqnam.
    DATA: lv_module   TYPE rs38l_fnam.
    DATA: lv_defrfc   TYPE rfcdest.
    DATA: lv_rfc      TYPE rfcdest.
    DATA: ls_context  TYPE zmqba_api_s_bpr_sub_call.
    DATA: lv_inbound  TYPE abap_bool.

* ------- check
    rv_success = abap_true.
    CHECK m_shm_config IS NOT INITIAL
      AND m_shm_config-subscribers[] IS NOT INITIAL.


* ------ prepare qrfc
    DATA(lr_qrfc) = zcl_mqba_factory=>create_util_qrfc( ).

    lv_qprefix = get_memory_param( iv_name = zif_mqba_broker=>c_param_subscribe_queue_name
                                   iv_def  = zif_mqba_broker=>c_param_subscribe_queue_def ).
    lv_defrfc  = get_memory_param( iv_name = zif_mqba_broker=>c_param_subscribe_rfcdest_name
                                   iv_def  = zif_mqba_broker=>c_param_subscribe_rfcdest_def ).

    lv_module  = get_memory_param( iv_name = zif_mqba_broker=>c_param_subscribe_bprmod_name
                                   iv_def  = zif_mqba_broker=>c_param_subscribe_bprmod_def ).
    IF lv_defrfc IS INITIAL.
      lv_defrfc = 'NONE'.
    ENDIF.



* ------- prepare data
    CLEAR ls_context.
    MOVE-CORRESPONDING m_shm_config-msg_data   TO ls_context-msg.
    MOVE-CORRESPONDING m_shm_config-msg_config TO ls_context-msg_cfg.


* ------- log point
    DESCRIBE TABLE m_shm_config-subscribers LINES DATA(lv_sub_cnt).
    LOG-POINT ID zmqba_int
       SUBKEY 'distribute_subscribers'
       FIELDS ls_context-msg-topic
              lv_sub_cnt
              lv_qprefix
              lv_defrfc
              lv_module.


* ------- loop all subscribers and process
    LOOP AT m_shm_config-subscribers INTO DATA(ls_sub_scfg).

* prepare data
      MOVE-CORRESPONDING ls_sub_scfg             TO ls_context-sub_cfg.


* read subscriber action config
      IF ls_sub_scfg-sub_action IS NOT INITIAL.

        READ TABLE m_shm_config-sub_actions INTO DATA(ls_sad)
          WITH KEY sub_action = ls_sub_scfg-sub_action.

        ASSERT ID zmqba_int
           SUBKEY 'subscriber_action_not_defined'
           FIELDS ls_sub_scfg-sub_action
        CONDITION sy-subrc EQ 0 AND ls_sad IS NOT INITIAL.

        MOVE-CORRESPONDING ls_sad TO ls_context-sub_act_cfg.

      ENDIF.


* prepare api call: destination and queue
      IF ls_sub_scfg-sub_dest IS NOT INITIAL.
        lv_rfc = lr_qrfc->get_rfc_dest_from_logsys( ls_sub_scfg-sub_dest  ).
      ELSE.
        lv_rfc = lv_defrfc.
      ENDIF.

      IF ls_sub_scfg-sub_qname IS NOT INITIAL.
        lv_qname = lv_qprefix && '-' && ls_sub_scfg-sub_qname.
      ELSE.
        lv_qname = lv_qprefix.
      ENDIF.

      IF lv_rfc IS INITIAL OR lv_rfc EQ 'NONE'.
        lv_inbound = abap_true.
      ELSE.
        lv_inbound = abap_false.
      ENDIF.


* log point
      LOG-POINT ID zmqba_int
         SUBKEY 'forward_to_subscriber'
         FIELDS ls_context-msg-topic
                ls_context-sub_cfg-sub_action
                ls_context-sub_cfg-sub_module
                lv_rfc
                lv_qname
                lv_inbound.

* open luw
      lr_qrfc->transaction_begin( ).

* set qname
      IF lr_qrfc->set_queue( iv_inbound = lv_inbound
                               iv_queue = lv_qname ) EQ abap_false.

        lv_error = abap_true.
        ASSERT ID zmqba_int
           SUBKEY 'forward_subscriber_set_queue'
           FIELDS ls_context-msg-topic
                  ls_context-sub_cfg-sub_action
                  ls_context-sub_cfg-sub_module
                  lv_rfc
                  lv_qname
        CONDITION lv_error EQ abap_false.
      ENDIF.


* call background processing
      CALL FUNCTION lv_module
        IN BACKGROUND TASK AS SEPARATE UNIT
        DESTINATION lv_rfc
        EXPORTING
          is_context = ls_context.

* finish
      lr_qrfc->transaction_end( ).

    ENDLOOP.



* final result
    rv_success = COND #( WHEN lv_error EQ abap_true
                         THEN abap_false
                         ELSE abap_true ).

  ENDMETHOD.


  METHOD get_memory_param.

    READ TABLE m_shm_config-brk_cfg INTO DATA(ls_cfgqp)
      WITH KEY param_name = iv_name.
    IF sy-subrc EQ 0 AND ls_cfgqp-param_value IS NOT INITIAL.
      rv_value = ls_cfgqp-param_value.
    ELSE.
      rv_value = iv_def.
    ENDIF.

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
    DO m_shm_retry TIMES.
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

*         force rebuild here
          IF m_exception IS INSTANCE OF cx_shm_inconsistent.
            zcl_mqba_factory=>rebuild_memory( ).
          ENDIF.
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

* ------ reset normal fields
    CLEAR: m_exception.

* ------ full reset
    IF iv_full EQ abap_true.
      CLEAR: m_shm_config.
    ENDIF.

  ENDMETHOD.


  METHOD send_gateway_message.

* ----- init and check
    IF ir_msg->get_scope( ) NE zif_mqba_broker=>c_scope_distributed.
      rv_success = abap_true.
      RETURN.
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


  METHOD zif_mqba_broker~external_messages_arrived.

* ============== INIT & PREPARE
* ---------- init
    CLEAR rs_result.
    rs_result-error_flag = abap_true.




    GET TIME STAMP FIELD: rs_result-proc_start,
                          rs_result-proc_end.

* ---------- check
    IF is_params IS INITIAL
      OR is_params-broker IS INITIAL.
      RETURN.
    ENDIF.

* ---------- prepare table
    DESCRIBE TABLE is_params-msgs LINES rs_result-cnt_all.
    IF rs_result-cnt_all EQ 0.
      rs_result-error_flag = abap_false.
      RETURN.
    ENDIF.


* ================ QRFC: check for queue processing
    IF is_params-flag_no_queue EQ abap_false.
      DATA(lr_bcfg) = zcl_mqba_factory=>get_broker_config( is_params-broker ).
      IF lr_bcfg IS INITIAL.
        RETURN.
      ENDIF.

      DATA(ls_cfg) = lr_bcfg->get_config( ).
      IF ls_cfg IS INITIAL.
        RETURN.
      ENDIF.

      IF ls_cfg-use_queue EQ abap_true.
        DATA(lr_qrfc) = zcl_mqba_factory=>create_util_qrfc( ).
        DATA(lv_qname) = ls_cfg-queue_name.
        IF lv_qname IS INITIAL.
          lv_qname = 'MQBA_INBOUND'.
        ENDIF.

        lr_qrfc->set_qrfc_inbound( lv_qname ).
        CALL FUNCTION 'Z_MQBA_API_EBROKER_QUEUE_PROC'
          IN BACKGROUND TASK AS SEPARATE UNIT
          DESTINATION 'NONE'
          EXPORTING
            iv_broker = is_params-broker
            it_msg    = is_params-msgs.
        lr_qrfc->transaction_end( ).

*       status and return
        rs_result-error_flag  = abap_false.
        rs_result-cnt_success = rs_result-cnt_all.
        RETURN.
      ENDIF.

    ENDIF.




* ===================== PROCESS
* ---------- loop all messages
    LOOP AT is_params-msgs ASSIGNING FIELD-SYMBOL(<lfs_in>).
*    prepare out
      APPEND INITIAL LINE TO rs_result-result ASSIGNING FIELD-SYMBOL(<lfs_out>).
      MOVE-CORRESPONDING <lfs_in> TO <lfs_out>.

*   create message from in
      DATA(lr_msg) = zcl_mqba_factory=>create_ext_message( ).
      IF lr_msg->set_data_from_ext_msg(
          is_msg     = <lfs_in>
          iv_broker  = is_params-broker
      ) EQ abap_false.
        <lfs_out>-error      = abap_true.
        <lfs_out>-error_text = 'wrong external message'.
        ADD 1 TO rs_result-cnt_error.
      ELSE.
*   forward to single processing
        IF zif_mqba_broker~external_message_arrived( lr_msg ) EQ abap_true.
          <lfs_out>-msg_guid   = lr_msg->zif_mqba_request~get_guid( ).
          <lfs_out>-msg_scope  = lr_msg->zif_mqba_request~get_scope( ).
          ADD 1 TO rs_result-cnt_success.
        ELSE.
          <lfs_out>-error      = abap_true.
          <lfs_out>-error_text = zif_mqba_broker~get_last_error( ).
          ADD 1 TO rs_result-cnt_error.
        ENDIF.
      ENDIF.

    ENDLOOP.

* ------------ fill result
    GET TIME STAMP FIELD rs_result-proc_end.
    rs_result-error_flag = COND #( WHEN rs_result-cnt_error EQ 0
                                   THEN abap_false ELSE abap_true ).

  ENDMETHOD.


  METHOD zif_mqba_broker~external_message_arrived.


* ------ set default
    reset( abap_true ). "full reset
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


  METHOD zif_mqba_broker~external_message_publish.

* ---------- init
    rv_success = abap_false.
    CLEAR m_exception.


* ---------- get an instance
    DATA(lr_ebroker) = zcl_mqba_factory=>get_broker_proxy( iv_broker_id ).
    IF lr_ebroker IS INITIAL.
      create_exception( |unknown broker { iv_broker_id }| ).
      RETURN.
    ENDIF.


* ----------- connect
    IF lr_ebroker->connect( ) EQ abap_false.
      create_exception( |connection failed to { iv_broker_id }| ).
      lr_ebroker->destroy( ).
      RETURN.
    ENDIF.


* ----------- publish
    IF lr_ebroker->publish(
         iv_topic   = iv_topic
         iv_payload = iv_payload
       ) EQ abap_false.
      create_exception( |publish failed to { iv_broker_id }| ).
    ELSE.
      rv_success = abap_true.
    ENDIF.


* ------------ destoy
    lr_ebroker->destroy( ).

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

*         force rebuild here
          IF m_exception IS INSTANCE OF cx_shm_inconsistent.
            zcl_mqba_factory=>rebuild_memory( ).
          ENDIF.

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


  METHOD zif_mqba_broker~get_statistic.

    DO m_shm_retry TIMES.
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

*         force rebuild here
          IF m_exception IS INSTANCE OF cx_shm_inconsistent.
            zcl_mqba_factory=>rebuild_memory( ).
          ENDIF.
      ENDTRY.
    ENDDO.

  ENDMETHOD.


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
