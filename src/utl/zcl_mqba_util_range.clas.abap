class ZCL_MQBA_UTIL_RANGE definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_UTIL_RANGE .
protected section.

  data M_RANGE type ZMQBA_RNG_T_STRING .
private section.
ENDCLASS.



CLASS ZCL_MQBA_UTIL_RANGE IMPLEMENTATION.


  METHOD zif_mqba_util_range~add.

* local data
    DATA: ls_line LIKE LINE OF m_range.

* prepare
    ls_line-sign = 'I'.
    ls_line-low  = iv_data.

    IF iv_data CS '*'.
      ls_line-option = 'CP'.
    ELSE.
      ls_line-option = 'EQ'.
    ENDIF.

* add to internal table
    APPEND ls_line TO m_range.

* return me
    rr_self = me.

  ENDMETHOD.


  METHOD zif_mqba_util_range~add_interval.

* local data
    DATA: ls_line LIKE LINE OF m_range.

* prepare
    ls_line-sign = 'I'.
    ls_line-option = 'BT'.
    ls_line-low  = iv_from.
    ls_line-high = iv_to.

* add to internal table
    APPEND ls_line TO m_range.

* return me
    rr_self = me.

  ENDMETHOD.


  METHOD zif_mqba_util_range~add_op.

* local data
    DATA: ls_line LIKE LINE OF m_range.

* prepare
    ls_line-sign = 'I'.
    ls_line-option = iv_option.
    ls_line-low  = iv_data.

* add to internal table
    APPEND ls_line TO m_range.

* return me
    rr_self = me.

  ENDMETHOD.


  METHOD zif_mqba_util_range~check.
    rv_success = COND #( WHEN iv_data IN m_range
                         THEN abap_true
                         ELSE abap_false ).
  ENDMETHOD.


  METHOD zif_mqba_util_range~get_count.
    DESCRIBE TABLE m_range LINES rv_count.
  ENDMETHOD.


  METHOD zif_mqba_util_range~get_range.
    rt_range = m_range.
  ENDMETHOD.


  METHOD zif_mqba_util_range~is_empty.
    rv_empty = COND #( WHEN m_range[] IS INITIAL
                       THEN abap_true
                       ELSE abap_false ).
  ENDMETHOD.


  METHOD zif_mqba_util_range~reset.
    CLEAR m_range.
  ENDMETHOD.
ENDCLASS.
