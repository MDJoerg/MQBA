class ZCL_MQBA_SHM_BL_MEMORY definition
  public
  create public
  shared memory enabled .

public section.

  methods STATISTIC_GET
    returning
      value(RS_STATISTIC) type ZMQBA_SHM_S_STC .
  methods STATISTIC_RESET .
  methods INITIALIZE .
  methods DESTROY .
  methods MESSAGE_PUT
    importing
      !IR_MSG type ref to ZIF_MQBA_REQUEST
    returning
      value(RS_CONFIG) type ZMQBA_SHM_S_PMG_OUT .
  methods READ_MSG_MEMORY
    importing
      !IS_PARAMS type ZMQBA_API_S_BRK_MSG_IN
    returning
      value(RS_RESULT) type ZMQBA_API_S_BRK_MSG .
  methods CHECK_VALID_MSG_GWI
    importing
      !IV_TOPIC type DATA
      !IV_DEFAULT type ABAP_BOOL default ABAP_FALSE
    returning
      value(RV_VALID) type ABAP_BOOL .
  methods CONSTRUCTOR .
protected section.

  data MT_MSG type ZMQBA_SHM_T_MSG .
  data MS_STAT type ZMQBA_SHM_S_STC .
  data MS_CUST type ZMQBA_SHM_S_CUS .
  constants C_BROKER_INTF type STRING value 'ZIF_MQBA_BROKER' ##NO_TEXT.

  methods SUBSCRIBER_INIT .
  methods CLEANUP .
  methods CONFIG_DESTROY .
  methods SUBSCRIBER_GET
    importing
      !IV_TOPIC type DATA
    returning
      value(RT_SUBSCRIBERS) type ZMQBA_SHM_T_CFG_SUB .
  methods STATISTIC_INIT .
  methods STATISTIC_DESTROY .
  methods MESSAGE_DESTROY .
  methods MESSAGE_INIT .
  methods CONFIG_GET_PARAM_BOOL
    importing
      !IV_PARAM type DATA
    returning
      value(RV_PARAM) type ABAP_BOOL .
  methods CONFIG_GET_PARAM_INT
    importing
      !IV_PARAM type DATA
    returning
      value(RV_PARAM) type I .
  methods CONFIG_GET_PARAM_STRING
    importing
      !IV_PARAM type DATA
    returning
      value(RV_PARAM) type STRING .
  methods PARAM_GET_NAME
    importing
      !IV_PARAM type DATA
    returning
      value(RV_NAME) type STRING .
  methods PARAM_GET_DEFAULT
    importing
      !IV_PARAM type DATA
    returning
      value(RV_PARAM) type STRING .
  methods PARAM_GET_CONFIG
    importing
      !IV_PARAM type DATA
      !IV_DEFAULT type DATA optional
    returning
      value(RV_PARAM) type STRING .
  methods CONFIG_INIT .
  methods HISTORY_ADD
    importing
      !IS_MSG type ZMQBA_SHM_S_MSG
      !IS_MSG_CFG type ZMQBA_MSG_S_CFG
    changing
      !CT_HISTORY type ZMQBA_MSG_T_MAIN .
  methods HISTORY_SAVE .
  methods MESSAGE_GET_CONFIG
    importing
      !IV_TOPIC type DATA
    returning
      value(RS_CONFIG) type ZMQBA_MSG_S_CFG .
  methods STATISTIC_PREPARE .
private section.
ENDCLASS.



CLASS ZCL_MQBA_SHM_BL_MEMORY IMPLEMENTATION.


  METHOD check_valid_msg_gwi.

* ----- default false and check topic
    rv_valid = iv_default.
    CHECK iv_topic IS NOT INITIAL.


* ------ check against lists
    TRY.
* check against blacklist
        DATA(lv_black) = COND #( WHEN iv_topic IN ms_cust-gwi_blacklist_rg
                                 THEN abap_true
                                 ELSE abap_false ).

* check against whitelist
        DATA(lv_white) = COND #( WHEN iv_topic IN ms_cust-gwi_whitelist_rg
                                 THEN abap_true
                                 ELSE abap_false ).


* build result
        rv_valid = COND #( WHEN lv_white EQ abap_true
                             OR lv_black EQ abap_false
                           THEN abap_true
                           ELSE abap_false ).

* statistic and log point
        "statistic_prepare( ).

        IF rv_valid EQ abap_false.
          "ADD 1 TO ms_stat-gwi_filtered.

          LOG-POINT ID zmqba_gw
           SUBKEY 'GW_INVALID_INBOUND_MSG'
           FIELDS iv_topic lv_black lv_white rv_valid.

        ELSE.
          "ADD 1 TO ms_stat-gwi_routed.
        ENDIF.

* ------ error handling
      CATCH cx_root
        INTO DATA(lr_exception).
        rv_valid = abap_true.
    ENDTRY.

  ENDMETHOD.


  METHOD cleanup.

* ---------- check for next cleanup time
    DATA(lv_now) = zcl_mqba_factory=>get_now( ).
    CHECK ms_stat-cleanup_next IS INITIAL
       OR lv_now          GT ms_stat-cleanup_next.


* ---------- cleanup message table
    DELETE mt_msg WHERE expire LT lv_now.


* ---------- calculate new interval
    DATA(lv_interval) = config_get_param_int( 'CLEANUP_INTERVAL' ).
    IF lv_interval EQ 0.
      lv_interval = 300.
    ENDIF.

* ----------- set statistics
    ms_stat-cleanup_next = lv_now + lv_interval.
    ms_stat-cleanup_last = lv_now.

  ENDMETHOD.


  method CONFIG_DESTROY.
  endmethod.


  method CONFIG_GET_PARAM_BOOL.
*  get param value as string cast to bool
   rv_param = param_get_config( iv_param ).
  endmethod.


  METHOD CONFIG_GET_PARAM_INT.
*  get param value as string cast to int
   rv_param = param_get_config( iv_param ).
  ENDMETHOD.


  METHOD CONFIG_GET_PARAM_STRING.
*  get param value as string
   rv_param = param_get_config( iv_param ).
  ENDMETHOD.


  METHOD config_init.

* ------ reset all
    CLEAR ms_cust.


* ------ general broker parameters (cust table ZTC_MQBACPD or default from broker interface
    DATA(lv_now) = zcl_mqba_factory=>get_base_date( ).

    SELECT * FROM ztc_mqbacpd
      INTO CORRESPONDING FIELDS OF TABLE ms_cust-params
     WHERE valid_from LE lv_now
       AND valid_to   GE lv_now
       AND activated  EQ abap_true.


* ------ gateway inbound
* blacklist
    DATA(lr_gwibl) = zcl_mqba_factory=>create_topic_filter_config( 'ZTC_MQBAGIBL' ).
    ms_cust-gwi_blacklist_cf = lr_gwibl->get_config_table( ).
    ms_cust-gwi_blacklist_rg = lr_gwibl->get_range( )->get_range( ).
* whitelist
    DATA(lr_gwiwl) = zcl_mqba_factory=>create_topic_filter_config( 'ZTC_MQBAGIWL' ).
    ms_cust-gwi_whitelist_cf = lr_gwiwl->get_config_table( ).
    ms_cust-gwi_whitelist_rg = lr_gwiwl->get_range( )->get_range( ).


* ------- finally set current time
    ms_cust-loaded_at = zcl_mqba_factory=>get_now( ).

  ENDMETHOD.


  METHOD constructor.

* ---- initialize: helper, ...
    initialize( ).


  ENDMETHOD.


  method DESTROY.

* -------- cleanup and flush some data to database
  message_destroy( ).
  config_destroy( ).
  statistic_destroy( ).


  endmethod.


  METHOD history_add.

* ----- local data
    DATA: ls_msg LIKE LINE OF ct_history.

* ----- check
    CHECK is_msg IS NOT INITIAL.
    CHECK config_get_param_bool( 'HISTORY_ENABLED' ) EQ abap_true.

* ----- append to history store
    MOVE-CORRESPONDING is_msg TO ls_msg.
    APPEND ls_msg TO ct_history.

** ----- save to database required
*    DATA(lv_max) = get_param_int( 'HISTORY_MAX' ).
*    DESCRIBE TABLE ct_history LINES DATA(lv_count).
*
*    IF lv_max = 0 OR lv_count GE lv_max.
*      history_save( ).
*    ENDIF.

  ENDMETHOD.


  METHOD HISTORY_SAVE.

* ------ local data
    DATA: ls_hist TYPE zmqba_shm_s_hst.
    DATA: lv_qname TYPE trfcqnam.
*
** ------ check
*    CHECK mt_history[] IS NOT INITIAL.
*
** ------ build api params and reset history
*    ls_hist-msg = mt_history.
*    CLEAR mt_history.
*
** ------ get parameters
*    DATA(lv_queue)   = get_param_string( 'HISTORY_QUEUE' ).
*    DATA(lv_module)  = get_param_string( 'HISTORY_BPRMOD' ).
*    DATA(lv_dest)    = get_param_string( 'HISTORY_RFCDEST' ).
*
*
** ------ call update module
*     lv_qname = lv_queue.
*
*    SET UPDATE TASK LOCAL.
*
*    CALL FUNCTION 'TRFC_SET_QIN_PROPERTIES'
*      EXPORTING
*        qin_name           = lv_qname
*      EXCEPTIONS
*        invalid_queue_name = 1
*        OTHERS             = 2.
*
*    ASSERT ID zmqba_shm
*       SUBKEY 'history_save_wrong_queue'
*       FIELDS lv_qname lv_module lv_dest
*       CONDITION sy-subrc EQ 0.
*
*    CALL FUNCTION lv_module
*      IN BACKGROUND TASK AS SEPARATE UNIT
*      DESTINATION lv_dest
*      EXPORTING
*        is_data = ls_hist.
*
*    COMMIT WORK.


** ------- final log
*    LOG-POINT ID zmqba_shm
*      SUBKEY 'history_saved'
*      FIELDS lv_qname lv_dest lv_module.
*
*
  ENDMETHOD.


  METHOD initialize.

* ================== init topic based filters
    TRY.

* ------ init statistic
        statistic_init( ).


* ------ init configuration
        config_init( ).

* ------ message store init
        message_init( ).

* ------ subscriber init
        subscriber_init( ).


* ------ error handling
      CATCH cx_root
      INTO DATA(lr_exception).
        ASSERT ID zmqba_shm
          SUBKEY 'shma_init_list_failed'
          FIELDS  lr_exception->get_text( )
          CONDITION abap_true = abap_false.
    ENDTRY.

  ENDMETHOD.


  method MESSAGE_DESTROY.
  endmethod.


  METHOD message_get_config.

* ----- check cache for existing topic
    READ TABLE ms_cust-msg_cache INTO DATA(ls_cfg)
      WITH KEY topic = iv_topic.

* ----- not existing: check and add to cache
    IF sy-subrc NE 0.
      LOOP AT ms_cust-msg_config INTO DATA(ls_cust).
        IF iv_topic CP ls_cust-topic.
          MOVE-CORRESPONDING ls_cust TO ls_cfg.
          ls_cfg-topic = iv_topic.
          EXIT.
        ENDIF.
      ENDLOOP.

      APPEND ls_cfg TO ms_cust-msg_cache.

    ENDIF.

* ------ finally fill output
    MOVE-CORRESPONDING ls_cfg TO rs_config.

  ENDMETHOD.


  METHOD message_init.

* -------- local data
    DATA: ls_cfg LIKE LINE OF ms_cust-msg_config.

* -------- init prepare
    DATA(lv_date) = zcl_mqba_factory=>get_base_date( ).
    CLEAR: ms_cust-sub_config.


* -------- select all table data
    SELECT * FROM ztc_mqbacmp
      INTO TABLE @DATA(lt_db)
     WHERE activated  EQ @abap_true
       AND valid_from LE @lv_date
       AND valid_to   GE @lv_date
     ORDER BY sort_order.

    CHECK lt_db[] IS NOT INITIAL.

* -------- loop all entries and build internal structure
    LOOP AT lt_db INTO DATA(ls_db).
      MOVE-CORRESPONDING ls_db TO ls_cfg.
      APPEND ls_cfg TO ms_cust-msg_config.
    ENDLOOP.

  ENDMETHOD.


  METHOD message_put.

* ---- local data
    FIELD-SYMBOLS <lfs_msg> LIKE LINE OF mt_msg.
    DATA: ls_cfg LIKE rs_config.

* ---- prepare and check
    CLEAR rs_config.
    ls_cfg-valid_for_dist = abap_false.
    DATA(lv_topic) = ir_msg->get_topic( ).
    CHECK lv_topic IS NOT INITIAL.


* ---- get message config
    DATA(ls_msg_cfg) = message_get_config( lv_topic ).
    ls_cfg-valid_for_dist = abap_true.
    ls_cfg-msg_config = ls_msg_cfg.


* ---- check existing
    READ TABLE mt_msg WITH TABLE KEY topic = lv_topic ASSIGNING <lfs_msg>.
    IF <lfs_msg> IS ASSIGNED.
      IF <lfs_msg>-payload EQ ir_msg->get_payload( ).
*       already known value
        ADD 1 TO <lfs_msg>-repeats.
        ls_cfg-valid_for_dist = abap_false.
      ELSE.
*       payload is different, put to history and process as new message
        DATA(lt_history) = <lfs_msg>-history.
        history_add( EXPORTING is_msg = <lfs_msg> is_msg_cfg = ls_msg_cfg CHANGING ct_history = lt_history ).
        CLEAR: <lfs_msg>-payload,
               <lfs_msg>-msg_props,
               <lfs_msg>-repeats.
        <lfs_msg>-history = lt_history.
      ENDIF.
    ELSE.
*       not known, create a new line
      APPEND INITIAL LINE TO mt_msg ASSIGNING <lfs_msg>.
    ENDIF.



* ---- fill line
* for initial lines...
    IF <lfs_msg>-payload IS INITIAL.
      <lfs_msg>-topic   = ir_msg->get_topic( ).
      <lfs_msg>-payload = ir_msg->get_payload( ).
      <lfs_msg>-repeats = 1.
      <lfs_msg>-created = ir_msg->get_timestamp( ).
    ENDIF.


* for all lines...
    <lfs_msg>-updated     = ir_msg->get_timestamp( ).
    <lfs_msg>-context     = ir_msg->get_context( ).
    <lfs_msg>-sender      = ir_msg->get_sender( ).
    <lfs_msg>-sender_ref  = ir_msg->get_id( ).
    <lfs_msg>-msg_guid    = ir_msg->get_guid( ).
    <lfs_msg>-msg_scope   = ir_msg->get_scope( ).

* fill expiration
    DATA(lv_expiration)     = config_get_param_int( 'MESSAGE_EXPIRE' ).
    IF ls_msg_cfg-expiration IS NOT INITIAL.
      lv_expiration = ls_msg_cfg-expiration.
    ENDIF.
    IF lv_expiration GT 0.
      <lfs_msg>-expire = <lfs_msg>-updated + lv_expiration.
    ENDIF.

* fill properties
    CLEAR <lfs_msg>-msg_props.
    LOOP AT ir_msg->get_properties( ) ASSIGNING FIELD-SYMBOL(<lfs_name>).
      APPEND INITIAL LINE TO <lfs_msg>-msg_props ASSIGNING FIELD-SYMBOL(<lfs_line>).
      <lfs_line>-name = <lfs_name>.
      <lfs_line>-value = ir_msg->get_property( <lfs_name> ).
    ENDLOOP.
* store to output
    MOVE-CORRESPONDING <lfs_msg> TO ls_cfg-msg_data.

* -------- check subscribers
    ls_cfg-subscribers = subscriber_get( lv_topic ).


* -------- statistics
    statistic_prepare( ).
    ADD 1 TO ms_stat-msg_processed.

* -------- cleanup
    cleanup( ).


* -------- fill result
    rs_config = ls_cfg.

  ENDMETHOD.


  METHOD param_get_config.

*  get the broker default first
    DATA(lv_default) = param_get_default( iv_param ).
    IF lv_default IS INITIAL.
      lv_default = iv_default.
    ENDIF.


*  get from customizing table
    DATA(lv_name) = param_get_name( iv_param ).
    READ TABLE ms_cust-params INTO DATA(ls_config)
     WITH KEY param_name = lv_name.
    IF sy-subrc EQ 0.
      rv_param = ls_config-param_value.
    ELSE.
      rv_param = lv_default.
    ENDIF.


*   log point
    LOG-POINT ID zmqba_shm
      SUBKEY 'param_get_config'
      FIELDS lv_name
             lv_default
             rv_param.

  ENDMETHOD.


  METHOD param_get_default.

*   get parameter name
    DATA(lv_name) = param_get_name( iv_param ).

*   build access name
    DATA(lv_prefix)   = |{ c_broker_intf }=>C_PARAM_{ iv_param }|.
    DATA(lv_default)  = lv_prefix && '_DEF'.

*   assign field symbols
    ASSIGN (lv_default) TO FIELD-SYMBOL(<lfs_default>).

*   assert
    ASSERT ID zmqba_shm
     SUBKEY 'get_param_default_failed'
     FIELDS lv_name lv_default
    CONDITION lv_name IS NOT INITIAL AND <lfs_default> IS ASSIGNED.

*   not found? set default
    rv_param = <lfs_default>.

  ENDMETHOD.


  METHOD param_get_name.

*   build access name
    DATA(lv_prefix)   = |{ c_broker_intf }=>C_PARAM_{ iv_param }|.
    DATA(lv_name)     = lv_prefix && '_NAME'.

*   assign field symbols
    ASSIGN (lv_name) TO FIELD-SYMBOL(<lfs_name>).

*   assert
    ASSERT ID zmqba_shm
     SUBKEY 'get_param_name_failed'
     FIELDS lv_name
    CONDITION <lfs_name> IS ASSIGNED.


*   not found? set default
    rv_name = <lfs_name>.
  ENDMETHOD.


  METHOD READ_MSG_MEMORY.

* ------ local macro definition

    " &1 name of the field
    DEFINE build_range.
      DATA: lrt_&1 LIKE RANGE OF is_params-&1.
      DATA: lrs_&1 LIKE LINE OF lrt_&1.

      IF is_params-&1 IS NOT INITIAL.
        lrs_&1-sign   = 'I'.
        lrs_&1-low    = is_params-&1.
        IF is_params-&1 CS '*'.
          lrs_&1-option = 'CP'.
        ELSE.
          lrs_&1-option = 'EQ'.
        ENDIF.
        APPEND lrs_&1 TO lrt_&1.
      ENDIF.
    END-OF-DEFINITION.


* ------ prepare loop
* build ranges
    build_range topic.
    build_range sender.
    build_range sender_ref.
    build_range context.

* ------ loop all with filters and prepare export
    LOOP AT mt_msg ASSIGNING FIELD-SYMBOL(<lfs_msg>)
      WHERE topic       IN lrt_topic
        AND sender      IN lrt_sender
        AND sender_ref  IN lrt_sender_ref
        AND context     IN lrt_context
        AND updated     GT is_params-ts_from.

*     append message and count
      APPEND INITIAL LINE TO rs_result-msg ASSIGNING FIELD-SYMBOL(<lfs_msg_out>).
      MOVE-CORRESPONDING <lfs_msg> TO <lfs_msg_out>.
      ADD 1 TO rs_result-msg_cnt_sel.
*     check timestamps
      IF rs_result-msg_ts_first IS INITIAL
        OR rs_result-msg_ts_first GT <lfs_msg>-created.
        rs_result-msg_ts_first = <lfs_msg>-created.
      ENDIF.
      IF rs_result-msg_ts_last IS INITIAL
          OR rs_result-msg_ts_last LT <lfs_msg>-updated.
        rs_result-msg_ts_last = <lfs_msg>-updated.
      ENDIF.
*     check for properties and append
      IF <lfs_msg>-msg_props[] IS NOT INITIAL.
        LOOP AT <lfs_msg>-msg_props ASSIGNING FIELD-SYMBOL(<lfs_prp>).
          APPEND INITIAL LINE TO rs_result-msg_prp ASSIGNING FIELD-SYMBOL(<lfs_prp_out>).
          <lfs_prp_out>-msg_guid = <lfs_msg>-msg_guid.
          MOVE-CORRESPONDING <lfs_prp> TO <lfs_prp_out>.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

* ------ fill other output
    DESCRIBE TABLE mt_msg LINES rs_result-msg_cnt_all.


  ENDMETHOD.


  method STATISTIC_DESTROY.

" do nothing at the moment, but later the data could be saved to database?


  endmethod.


  METHOD statistic_get.
    rs_statistic = ms_stat.
  ENDMETHOD.


  METHOD statistic_init.
    CLEAR ms_stat.
  ENDMETHOD.


  METHOD statistic_prepare.

*   check for initial state and set default
    IF ms_stat IS INITIAL.
      ms_stat-created = zcl_mqba_factory=>get_now( ) - 1. " division / 0
    ENDIF.

*   set current timestamp to updated
    ms_stat-updated = zcl_mqba_factory=>get_now( ).

  ENDMETHOD.


  METHOD statistic_reset.
    statistic_destroy( ).
    statistic_init( ).
  ENDMETHOD.


  METHOD subscriber_get.

* ----- init check
    CHECK ms_cust-sub_config[] IS NOT INITIAL.

* ----- loop
    LOOP AT ms_cust-sub_config INTO DATA(ls_cfg).
      IF iv_topic CP ls_cfg-topic.
        APPEND INITIAL LINE TO rt_subscribers ASSIGNING FIELD-SYMBOL(<lfs_line>).
        MOVE-CORRESPONDING ls_cfg TO <lfs_line>.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD subscriber_init.

* -------- local data
    DATA: ls_cfg LIKE LINE OF ms_cust-sub_config.

* -------- init prepare
    DATA(lv_date) = zcl_mqba_factory=>get_base_date( ).
    CLEAR: ms_cust-sub_config.


* -------- select all table data
    SELECT * FROM ztc_mqbacsa
      INTO TABLE @DATA(lt_db)
     WHERE activated  EQ @abap_true
       AND valid_from LE @lv_date
       AND valid_to   GE @lv_date
     ORDER BY sort_order.

    CHECK lt_db[] IS NOT INITIAL.

* -------- loop all entries and build internal structure
    LOOP AT lt_db INTO DATA(ls_db).
      MOVE-CORRESPONDING ls_db TO ls_cfg.
      APPEND ls_cfg TO ms_cust-sub_config.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
