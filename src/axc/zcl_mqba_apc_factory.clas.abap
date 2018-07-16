class ZCL_MQBA_APC_FACTORY definition
  public
  final
  create public .

public section.

  class-methods CREATE_CONTEXT
    importing
      !IR_CONTEXT type ref to IF_APC_WSP_SERVER_CONTEXT
    returning
      value(RR_INSTANCE) type ref to ZCL_MQBA_APC_CONTEXT .
  class-methods CREATE_MESSAGE
    importing
      !IR_MESSAGE type ref to IF_APC_WSP_MESSAGE optional
    returning
      value(RR_INSTANCE) type ref to ZCL_MQBA_APC_MESSAGE .
  class-methods CREATE_RESPONSE
    importing
      !IR_MSG_MGR type ref to IF_APC_WSP_MESSAGE_MANAGER
    returning
      value(RR_INSTANCE) type ref to ZCL_MQBA_APC_RESPONSE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MQBA_APC_FACTORY IMPLEMENTATION.


  METHOD create_context.
    DATA(lr_instance) = NEW zcl_mqba_apc_context( ).
    lr_instance->m_apc_context = ir_context.
    rr_instance = lr_instance.
  ENDMETHOD.


  METHOD create_message.
*   local data
    DATA lr_instance TYPE REF TO zcl_mqba_apc_message.
*   create instance and set initial data as friend
    lr_instance ?= zcl_mqba_message=>create( 'ZCL_MQBA_APC_MESSAGE' ).
    lr_instance->m_apc_message = ir_message.
*   fill export
    rr_instance = lr_instance.
  ENDMETHOD.


  METHOD create_response.
    DATA(lr_instance) = NEW zcl_mqba_apc_response( ).
    lr_instance->m_apc_message_mgr = ir_msg_mgr.
    rr_instance = lr_instance.
  ENDMETHOD.
ENDCLASS.
