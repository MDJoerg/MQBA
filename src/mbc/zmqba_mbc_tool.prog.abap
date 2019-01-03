*&---------------------------------------------------------------------*
*& Report ZMQBA_MBC_TOOL
*&---------------------------------------------------------------------*
*& Utility to set and read shared memory context
*&---------------------------------------------------------------------*
REPORT zmqba_mbc_tool NO STANDARD PAGE HEADING LINE-SIZE 1023.

* ------------ interface
PARAMETERS: p_grp TYPE zmqba_param_group DEFAULT 'TEST'.
PARAMETERS: p_par TYPE zmqba_param.
PARAMETERS: p_val TYPE zmqba_value_string.
SELECTION-SCREEN: ULINE.
PARAMETERS: p_lgp RADIOBUTTON GROUP opti DEFAULT 'X'.   " list groups
PARAMETERS: p_lpr RADIOBUTTON GROUP opti.               " list params
PARAMETERS: p_set RADIOBUTTON GROUP opti.               " set param
PARAMETERS: p_rem RADIOBUTTON GROUP opti.               " remove param
PARAMETERS: p_del RADIOBUTTON GROUP opti.               " delete group params



DEFINE error_exit.
  WRITE: / &1 COLOR 6.
  RETURN.
END-OF-DEFINITION.


START-OF-SELECTION.

* -------- get handler
  DATA(lr_util) = zcl_mqba_factory=>get_shm_context( ).
  IF lr_util IS INITIAL.
    error_exit 'shared memory handler failed'.
  ENDIF.

* -------- set group
  lr_util->set_group( p_grp ).


* -------- process
  CASE 'X'.
    WHEN p_lgp.
*     groups
      DATA(lt_grp) = lr_util->get_groups( ).
      LOOP AT lt_grp ASSIGNING FIELD-SYMBOL(<lfs_grp>).
        WRITE: / <lfs_grp>.
      ENDLOOP.
    WHEN p_lpr.
*     LIST
      DATA(lt_param) = lr_util->get_tab( ).
      LOOP AT lt_param ASSIGNING FIELD-SYMBOL(<lfs_lst>).
        WRITE: / <lfs_lst>-param_name,
                 <lfs_lst>-param_value.
      ENDLOOP.
    WHEN p_set.
*     SET
      IF lr_util->put(
           iv_param   = p_par
           iv_value   = p_val ) EQ abap_true.
        WRITE: / |Parameter { p_par } set to { p_val }|.
      ELSE.
        error_exit 'error while setting parameter value'.
      ENDIF.
    WHEN p_rem.
*     REMOVE
      IF lr_util->remove( iv_param   = p_par ) EQ abap_true.
        WRITE: / |Parameter { p_par } removed|.
      ELSE.
        error_exit 'error while removing parameter'.
      ENDIF.
    WHEN p_del.
*     CLEAR GROUP
      IF lr_util->clear( ) EQ abap_true.
        WRITE: / |Group { p_grp } removed|.
      ELSE.
        error_exit 'error while removing group parameter'.
      ENDIF.
    WHEN OTHERS.
      error_exit 'unknown option or not implemented yet'.
  ENDCASE.
