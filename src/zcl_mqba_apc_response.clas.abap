class ZCL_MQBA_APC_RESPONSE definition
  public
  create public

  global friends ZCL_MQBA_APC_FACTORY .

public section.

  interfaces ZIF_MQBA_RESPONSE .
protected section.

  data M_APC_MESSAGE_MGR type ref to IF_APC_WSP_MESSAGE_MANAGER .
private section.
ENDCLASS.



CLASS ZCL_MQBA_APC_RESPONSE IMPLEMENTATION.


  METHOD zif_mqba_response~post_answer.

*  init and check
    CLEAR rv_success.
    CHECK m_apc_message_mgr IS NOT INITIAL.

*  create new message and send
    DATA(lo_message) = m_apc_message_mgr->create_message( ).
    lo_message->set_text( iv_msg ).
    m_apc_message_mgr->send( lo_message ).

  ENDMETHOD.
ENDCLASS.
