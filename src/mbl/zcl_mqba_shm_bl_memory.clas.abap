class ZCL_MQBA_SHM_BL_MEMORY definition
  public
  create public
  shared memory enabled .

public section.

  methods INITIALIZE .
  methods PUT_MESSAGE
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
  data MT_RG_GWI_WHITELIST type ZMQBA_RNG_T_STRING .
  data MT_RG_GWI_BLACKLIST type ZMQBA_RNG_T_STRING .
  data MT_CF_GWI_BLACKLIST type ZMQBA_TBF_T_CFG .
  data MT_CF_GWI_WHITELIST type ZMQBA_TBF_T_CFG .
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
        DATA(lv_black) = COND #( WHEN iv_topic IN mt_rg_gwi_blacklist
                                 THEN abap_true
                                 ELSE abap_false ).

* check against whitelist
        DATA(lv_white) = COND #( WHEN iv_topic IN mt_rg_gwi_whitelist
                                 THEN abap_true
                                 ELSE abap_false ).


* build result
        rv_valid = COND #( WHEN lv_white EQ abap_true
                             OR lv_black EQ abap_false
                           THEN abap_true
                           ELSE abap_false ).
* log point for invalid
        IF rv_valid EQ abap_false.
          LOG-POINT ID zmqba_gw
           SUBKEY 'GW_INVALID_INBOUND_MSG'
           FIELDS iv_topic lv_black lv_white rv_valid.
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


  METHOD initialize.

* ================== init topic based filters
    TRY.

* ------ gateway inbound
* blacklist
        DATA(lr_gwibl) = zcl_mqba_factory=>create_topic_filter_config( 'ZTC_MQBAGIBL' ).
        mt_cf_gwi_blacklist = lr_gwibl->get_config_table( ).
        mt_rg_gwi_blacklist = lr_gwibl->get_range( )->get_range( ).
* whitelist
        DATA(lr_gwiwl) = zcl_mqba_factory=>create_topic_filter_config( 'ZTC_MQBAGIWL' ).
        mt_cf_gwi_whitelist = lr_gwiwl->get_config_table( ).
        mt_rg_gwi_whitelist = lr_gwiwl->get_range( )->get_range( ).

* ------ error handling
      CATCH cx_root
      INTO DATA(lr_exception).
        ASSERT ID zmqba_shm
          SUBKEY 'shma_init_list_failed'
          FIELDS  lr_exception->get_text( )
          CONDITION abap_true = abap_false.
    ENDTRY.

  ENDMETHOD.


  METHOD PUT_MESSAGE.

* ---- local data
    FIELD-SYMBOLS <lfs_msg> LIKE LINE OF mt_msg.
    DATA: ls_cfg LIKE rs_config.

* ---- prepare
    DATA(lv_topic) = ir_msg->get_topic( ).
    ls_cfg-valid_for_dist = abap_true.

* ---- check existing
    READ TABLE mt_msg WITH TABLE KEY topic = lv_topic ASSIGNING <lfs_msg>.
    IF <lfs_msg> IS ASSIGNED.
      IF <lfs_msg>-payload EQ ir_msg->get_payload( ).
*       already known value
        ADD 1 TO <lfs_msg>-repeats.
        ls_cfg-valid_for_dist = abap_false.
      ELSE.
*       payload is different, process as new message
        CLEAR <lfs_msg>.
      ENDIF.
    ELSE.
*       not known, create a new line
      APPEND INITIAL LINE TO mt_msg ASSIGNING <lfs_msg>.
    ENDIF.



* ---- fill line
* for initial lines...
    IF <lfs_msg> IS INITIAL.
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
ENDCLASS.
