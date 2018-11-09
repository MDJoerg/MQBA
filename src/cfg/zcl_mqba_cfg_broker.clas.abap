class ZCL_MQBA_CFG_BROKER definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_CFG_BROKER .
protected section.

  data MV_ID type STRING .
  data MS_CONFIG type ZMQBA_API_S_BRK_CFG .
private section.
ENDCLASS.



CLASS ZCL_MQBA_CFG_BROKER IMPLEMENTATION.


  METHOD zif_mqba_cfg_broker~get_config.
    CHECK mv_id IS NOT INITIAL.

    IF ms_config IS INITIAL.
      SELECT SINGLE *
        FROM ztc_mqbabrk
        INTO CORRESPONDING FIELDS OF ms_config
       WHERE broker_id = mv_id.
    ENDIF.

    rs_config = ms_config.

  ENDMETHOD.


  method ZIF_MQBA_CFG_BROKER~GET_ID.
    rv_id = mv_id.
  endmethod.


  METHOD zif_mqba_cfg_broker~is_valid.
    CHECK mv_id IS NOT INITIAL
      AND ms_config IS NOT INITIAL.
    rv_valid = abap_true.
  ENDMETHOD.


  METHOD zif_mqba_cfg_broker~set_id.
    mv_id = iv_id.
    rr_self = me.
  ENDMETHOD.
ENDCLASS.
