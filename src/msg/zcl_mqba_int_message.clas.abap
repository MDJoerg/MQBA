class ZCL_MQBA_INT_MESSAGE definition
  public
  inheriting from ZCL_MQBA_MESSAGE
  create public .

public section.

  methods CREATE_PCP_MESSAGE
    returning
      value(RR_PCP_MSG) type ref to IF_AC_MESSAGE_TYPE_PCP .
  methods SET_DATA_FROM_APC_MSG
    importing
      !IR_MSG type ref to IF_APC_WSP_MESSAGE
    returning
      value(RR_SELF) type ref to ZCL_MQBA_INT_MESSAGE .
  methods SET_DATA_FROM_PCP
    importing
      !IR_PCP_MSG type ref to IF_AC_MESSAGE_TYPE_PCP
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MQBA_INT_MESSAGE IMPLEMENTATION.


  METHOD create_pcp_message.

*       create a pcp me->ZIF_MQBA_REQUEST~ssage
    rr_pcp_msg = cl_ac_message_type_pcp=>create( ).

*       fill payload and other mqba fields
    rr_pcp_msg->set_text( me->zif_mqba_request~get_payload( ) ).
    rr_pcp_msg->set_field(  i_name = zif_mqba_broker=>c_int_field_prefix && zif_mqba_broker=>c_int_field_topic i_value = me->zif_mqba_request~get_topic( ) ).
    rr_pcp_msg->set_field(  i_name = zif_mqba_broker=>c_int_field_prefix && zif_mqba_broker=>c_int_field_context i_value = me->zif_mqba_request~get_context( ) ).
    rr_pcp_msg->set_field(  i_name = zif_mqba_broker=>c_int_field_prefix && zif_mqba_broker=>c_int_field_sender i_value = me->zif_mqba_request~get_sender( ) ).
    rr_pcp_msg->set_field(  i_name = zif_mqba_broker=>c_int_field_prefix && zif_mqba_broker=>c_int_field_ref i_value = me->zif_mqba_request~get_id( ) ).
    rr_pcp_msg->set_field(  i_name = zif_mqba_broker=>c_int_field_prefix && zif_mqba_broker=>c_int_field_msgguid i_value = me->zif_mqba_request~get_guid( ) ).
    rr_pcp_msg->set_field(  i_name = zif_mqba_broker=>c_int_field_prefix && zif_mqba_broker=>c_int_field_scope i_value = me->zif_mqba_request~get_scope( ) ).


*       fill additional fields
    DATA(lt_fields) = me->zif_mqba_request~get_properties( ).
    IF lt_fields[] IS NOT INITIAL.
      LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<lfs_name>).
        rr_pcp_msg->set_field( i_name = <lfs_name> i_value = me->zif_mqba_request~get_property( <lfs_name> ) ).
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD set_data_from_apc_msg.

* ------- local data
    DATA: lt_lines TYPE TABLE OF string.
    DATA: lv_pl_mode TYPE abap_bool.
    DATA: lv_name TYPE string.
    DATA: lv_value TYPE string.

* ------- check
    CHECK ir_msg IS NOT INITIAL.

* ------- get fulltext and split into lines
    DATA(lv_text) = ir_msg->get_text( ).

    SPLIT lv_text AT cl_abap_char_utilities=>newline INTO TABLE lt_lines.
    IF lt_lines[] IS NOT INITIAL.
*     loop
      LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<lfs_line>).

*     check for first empty line -> switch to payload detection
        IF <lfs_line> IS INITIAL.
          lv_pl_mode = abap_true.
        ENDIF.

*     process line
        IF     lv_pl_mode EQ abap_false
          AND  <lfs_line> CS ':'.
*     line is a field
          SPLIT <lfs_line> AT ':' INTO lv_name lv_value.
          CASE lv_name.
            WHEN 'pcp-action'.
            WHEN 'pcp-channel'.
            WHEN 'pcp-body-type'.
            WHEN 'mqba-scope'.
            WHEN 'mqba-msg_guid'.
            WHEN 'mqba-topic'.
              m_topic = lv_value.
            WHEN 'mqba-context'.
              m_context = lv_value.
            WHEN 'mqba-sender'.
              m_sender  = lv_value.
            WHEN 'mqba-sender_ref'.
              m_id = lv_value.
            WHEN OTHERS.
              set_property( iv_name = lv_name iv_value = lv_value ).
          ENDCASE.
        ELSE.
*     line is payload, concatenate
          IF m_payload IS INITIAL.
            m_payload = <lfs_line>.
          ELSE.
            m_payload = m_payload && cl_abap_char_utilities=>newline && <lfs_line>.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD set_data_from_pcp.

* ---- local data
    DATA: lt_fields TYPE pcp_fields.

* ---- init and check
    CLEAR rv_success.
    CHECK ir_pcp_msg IS BOUND.

* ---- fill message
    m_payload = ir_pcp_msg->get_text( ).

* ---- get pcp fields and loop all
    ir_pcp_msg->get_fields( CHANGING c_fields = lt_fields ).
    DATA(lv_mask)   = zif_mqba_broker=>c_int_field_prefix && '*'.

    LOOP AT lt_fields
      ASSIGNING FIELD-SYMBOL(<lfs_field>)
      WHERE name CP lv_mask.

      CASE <lfs_field>-name.
        WHEN zif_mqba_broker=>c_int_field_topic.
          m_topic = <lfs_field>-value.
        WHEN zif_mqba_broker=>c_int_field_sender.
          m_sender = <lfs_field>-value.
        WHEN zif_mqba_broker=>c_int_field_ref.
          m_id = <lfs_field>-value.
        WHEN zif_mqba_broker=>c_int_field_context.
          m_context = <lfs_field>-value.
        WHEN zif_mqba_broker=>c_int_field_msgguid.
          m_guid = <lfs_field>-value.
        WHEN zif_mqba_broker=>c_int_field_scope.
          m_scope = <lfs_field>-value.
        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.


* ---- finally true
    rv_success = abap_true.

  ENDMETHOD.
ENDCLASS.
