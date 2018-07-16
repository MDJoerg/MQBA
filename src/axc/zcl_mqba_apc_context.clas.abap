class ZCL_MQBA_APC_CONTEXT definition
  public
  create public

  global friends ZCL_MQBA_APC_FACTORY .

public section.

  interfaces ZIF_MQBA_CONTEXT .
protected section.

  data M_APC_CONTEXT type ref to IF_APC_WSP_SERVER_CONTEXT .
private section.
ENDCLASS.



CLASS ZCL_MQBA_APC_CONTEXT IMPLEMENTATION.
ENDCLASS.
