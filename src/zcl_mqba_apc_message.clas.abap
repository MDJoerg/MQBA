class ZCL_MQBA_APC_MESSAGE definition
  public
  inheriting from ZCL_MQBA_MESSAGE
  create public

  global friends ZCL_MQBA_APC_FACTORY .

public section.

  methods CREATE_OUTBOUND_TEXT_MESSAGE
    returning
      value(RV_TEXT) type STRING .
protected section.

  data M_APC_MESSAGE type ref to IF_APC_WSP_MESSAGE .
private section.
ENDCLASS.



CLASS ZCL_MQBA_APC_MESSAGE IMPLEMENTATION.


  METHOD create_outbound_text_message.


    rv_text =  '{'
            && | "topic": "{ m_topic }"|
            && |, "payload": "{ m_payload }"|
            && ' }'.

  ENDMETHOD.
ENDCLASS.
