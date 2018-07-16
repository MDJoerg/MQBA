class ZCL_MQBA_CFG_TOPIC_FILTER definition
  public
  create public
  shared memory enabled .

public section.

  interfaces ZIF_MQBA_CFG_TOPIC_FILTER .

  methods CONSTRUCTOR
    importing
      !IV_BASE_TAB type TABNAME .
protected section.

  data M_BASE_TAB type TABNAME .
  data M_RANGE type ref to ZIF_MQBA_UTIL_RANGE .
  data M_BASE_DATE type DATUM .
  data M_CONFIG type ZMQBA_TBF_T_CFG .

  methods INITIALIZE .
private section.
ENDCLASS.



CLASS ZCL_MQBA_CFG_TOPIC_FILTER IMPLEMENTATION.


  METHOD constructor.
    m_base_tab = iv_base_tab.
    initialize( ).
  ENDMETHOD.


  METHOD initialize.

* reset data and init utils
    CLEAR m_config.
    m_range = zcl_mqba_factory=>create_util_range( ).
    m_base_date = zcl_mqba_factory=>get_base_date( ).

* check base tab
    CHECK m_base_tab IS NOT INITIAL.

* read db
    SELECT * FROM (m_base_tab)
      INTO CORRESPONDING FIELDS OF TABLE m_config
     WHERE valid_from LE m_base_date
       AND valid_to   GE m_base_date
       AND activated  EQ abap_true.
    CHECK m_config[] IS NOT INITIAL.

* prepare after read
    LOOP AT m_config ASSIGNING FIELD-SYMBOL(<lfs_config>).
      IF <lfs_config>-topic IS NOT INITIAL.
*       calc len for later sorting
        <lfs_config>-topic_len = strlen( <lfs_config>-topic ).
*       build range
        m_range->add( <lfs_config>-topic ).
      ENDIF.
    ENDLOOP.

* sort table with sort order and len of topic mask
    SORT m_config
      BY sort_order DESCENDING
         topic_len  DESCENDING.

  ENDMETHOD.


  METHOD zif_mqba_cfg_topic_filter~get_config_for_topic.

* init and check
    CLEAR rs_config.
    CHECK iv_topic IS NOT INITIAL.

* loop and compare
    LOOP AT m_config ASSIGNING FIELD-SYMBOL(<lfs_config>).
      IF iv_topic CP <lfs_config>-topic.
        rs_config = <lfs_config>.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_mqba_cfg_topic_filter~get_config_table.
    rt_cfg = m_config.
  ENDMETHOD.


  METHOD zif_mqba_cfg_topic_filter~get_range.
    rr_range = m_range.
  ENDMETHOD.


  METHOD zif_mqba_cfg_topic_filter~is_configured.
* set default
    rv_configured = abap_false.
    CHECK iv_topic IS NOT INITIAL.

* check against range
    rv_configured = m_range->check( iv_topic ).
  ENDMETHOD.
ENDCLASS.
