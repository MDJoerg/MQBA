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
  methods MESSAGE_PUT
    importing
      !IR_MSG type ref to ZIF_MQBA_REQUEST
    returning
      value(RS_CONFIG) type ZMQBA_SHM_S_CFG .
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

  methods GET_PARAM_BOOL
    importing
      !IV_PARAM type DATA
    returning
      value(RV_PARAM) type ABAP_BOOL .
  methods GET_PARAM_INT
    importing
      !IV_PARAM type DATA
    returning
      value(RV_PARAM) type I .
  methods GET_PARAM_STRING
    importing
      !IV_PARAM type DATA
    returning
      value(RV_PARAM) type STRING .
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


  METHOD constructor.

* ---- initialize: helper, ...
    initialize( ).


  ENDMETHOD.


  method GET_PARAM_BOOL.

*   build access name
    data(lv_prefix)   = |ZIF_MQBA_BROKER=>C_PARAM_{ iv_param }|.
    data(lv_name)     = lv_prefix && '_NAME'.
    data(lv_default)  = lv_prefix && '_DEF'.

*   assign field symbols
    assign (lv_name) to field-symbol(<lfs_name>).
    assign (lv_default) to field-symbol(<lfs_default>).

*   assert
    ASSERT ID zmqba_shm
     SUBKEY 'get_param_string_failed'
     FIELDS lv_name lv_default
    CONDITION <lfs_name> IS ASSIGNED AND <lfs_default> IS ASSIGNED.


*   get from parameter table
"   TODO


*   not found? set default
    rv_param = <lfs_default>.

*   log point
    LOG-POINT ID zmqba_shm
      SUBKEY 'get_param_string'
      FIELDS lv_name     <lfs_name>
             lv_default  <lfs_default>.


  endmethod.


  METHOD get_param_int.
*   build access name
    DATA(lv_prefix)   = |ZIF_MQBA_BROKER=>C_PARAM_{ iv_param }|.
    DATA(lv_name)     = lv_prefix && '_NAME'.
    DATA(lv_default)  = lv_prefix && '_DEF'.

*   assign field symbols
    ASSIGN (lv_name) TO FIELD-SYMBOL(<lfs_name>).
    ASSIGN (lv_default) TO FIELD-SYMBOL(<lfs_default>).

*   assert
    ASSERT ID zmqba_shm
     SUBKEY 'get_param_string_failed'
     FIELDS lv_name lv_default
    CONDITION <lfs_name> IS ASSIGNED AND <lfs_default> IS ASSIGNED.


*   get from parameter table
    "   TODO


*   not found? set default
    rv_param = <lfs_default>.


*   log point
    LOG-POINT ID zmqba_shm
      SUBKEY 'get_param_string'
      FIELDS lv_name     <lfs_name>
             lv_default  <lfs_default>.

  ENDMETHOD.


  METHOD get_param_string.
*   build access name
    DATA(lv_prefix)   = |ZIF_MQBA_BROKER=>C_PARAM_{ iv_param }|.
    DATA(lv_name)     = lv_prefix && '_NAME'.
    DATA(lv_default)  = lv_prefix && '_DEF'.

*   assign field symbols
    ASSIGN (lv_name) TO FIELD-SYMBOL(<lfs_name>).
    ASSIGN (lv_default) TO FIELD-SYMBOL(<lfs_default>).

*   assert
    ASSERT ID zmqba_shm
     SUBKEY 'get_param_string_failed'
     FIELDS lv_name lv_default
    CONDITION <lfs_name> IS ASSIGNED AND <lfs_default> IS ASSIGNED.


*   get from parameter table
    "   TODO


*   not found? set default
    rv_param = <lfs_default>.

*   log point
    LOG-POINT ID zmqba_shm
      SUBKEY 'get_param_string'
      FIELDS lv_name     <lfs_name>
             lv_default  <lfs_default>.

  ENDMETHOD.


  METHOD history_add.

* ----- local data
    DATA: ls_msg LIKE LINE OF ct_history.

* ----- check
    CHECK is_msg IS NOT INITIAL.
    CHECK get_param_bool( 'HISTORY_ENABLED' ) EQ abap_true.

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

* ------ gateway inbound
* blacklist
        DATA(lr_gwibl) = zcl_mqba_factory=>create_topic_filter_config( 'ZTC_MQBAGIBL' ).
        ms_cust-gwi_blacklist_cf = lr_gwibl->get_config_table( ).
        ms_cust-gwi_blacklist_rg = lr_gwibl->get_range( )->get_range( ).
* whitelist
        DATA(lr_gwiwl) = zcl_mqba_factory=>create_topic_filter_config( 'ZTC_MQBAGIWL' ).
        ms_cust-gwi_whitelist_cf = lr_gwiwl->get_config_table( ).
        ms_cust-gwi_whitelist_rg = lr_gwiwl->get_range( )->get_range( ).

* ------ error handling
      CATCH cx_root
      INTO DATA(lr_exception).
        ASSERT ID zmqba_shm
          SUBKEY 'shma_init_list_failed'
          FIELDS  lr_exception->get_text( )
          CONDITION abap_true = abap_false.
    ENDTRY.

  ENDMETHOD.


  method MESSAGE_GET_CONFIG.
  endmethod.


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
    ls_cfg-valid_for_dist = abap_true.
    DATA(ls_msg_cfg) = message_get_config( lv_topic ).


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

* fill properties
    CLEAR <lfs_msg>-msg_props.
    LOOP AT ir_msg->get_properties( ) ASSIGNING FIELD-SYMBOL(<lfs_name>).
      APPEND INITIAL LINE TO <lfs_msg>-msg_props ASSIGNING FIELD-SYMBOL(<lfs_line>).
      <lfs_line>-name = <lfs_name>.
      <lfs_line>-value = ir_msg->get_property( <lfs_name> ).
    ENDLOOP.


* -------- statistics
    statistic_prepare( ).
    ADD 1 TO ms_stat-msg_processed.

* -------- fill result
    rs_config = ls_cfg.

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


  METHOD statistic_get.
    rs_statistic = ms_stat.
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
    CLEAR ms_stat.
  ENDMETHOD.
ENDCLASS.
