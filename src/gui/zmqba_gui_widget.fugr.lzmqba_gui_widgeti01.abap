*----------------------------------------------------------------------*
***INCLUDE LZMQBA_GUI_WIDGETI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_SEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_sen INPUT.
  IF gr_subscreen IS NOT INITIAL.
    gr_subscreen->pai( CHANGING cs_uidata = zmqba_gui_s_wgt_sen_out cv_ucomm = sy-ucomm ).
    CLEAR gr_subscreen.
  ENDIF.
ENDMODULE.

MODULE pai_swt INPUT.
  IF gr_subscreen IS NOT INITIAL.
    gr_subscreen->pai( CHANGING cs_uidata = zmqba_gui_s_wgt_swt_out cv_ucomm = sy-ucomm ).
    CLEAR gr_subscreen.
  ENDIF.
ENDMODULE.
