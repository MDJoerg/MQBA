class ZCL_MQBA_EXT_MESSAGE definition
  public
  inheriting from ZCL_MQBA_MESSAGE
  create public .

public section.

  methods SET_DATA_FROM_EXT_MSG
    importing
      !IS_MSG type ZMQBA_API_S_EBR_MSG
      !IV_BROKER type DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MQBA_EXT_MESSAGE IMPLEMENTATION.


  METHOD set_data_from_ext_msg.

* init
    IF iv_broker IS INITIAL
      OR is_msg IS INITIAL
      OR is_msg-topic IS INITIAL.
      rv_success = abap_false.
      RETURN.
    ENDIF.


* fill main data
    set_sender( iv_broker ).
    set_scope( zif_mqba_broker=>c_scope_external ).
    set_id( is_msg-msg_id ).
    set_topic( is_msg-topic ).
    set_payload( is_msg-payload ).

    IF is_msg-qos IS NOT INITIAL.
      set_property(
          iv_name  = 'QOS'
          iv_value = is_msg-qos
      ).
    ENDIF.

    IF is_msg-retain IS NOT INITIAL.
      set_property(
          iv_name  = 'RETAIN'
          iv_value = is_msg-retain
      ).
    ENDIF.

    rv_success = abap_true.

  ENDMETHOD.
ENDCLASS.
