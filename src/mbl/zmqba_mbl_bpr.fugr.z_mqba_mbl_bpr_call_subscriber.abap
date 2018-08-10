FUNCTION z_mqba_mbl_bpr_call_subscriber.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_MSG) TYPE  ZMQBA_MSG_S_MAIN
*"     VALUE(IS_CFG_MSG) TYPE  ZMQBA_SHM_S_CFG_MSG
*"     VALUE(IS_CFG_SUB) TYPE  ZMQBA_SHM_S_CFG_SUB
*"  EXCEPTIONS
*"      ERRORS_OCCURED
*"----------------------------------------------------------------------


  RAISE errors_occured.


ENDFUNCTION.
