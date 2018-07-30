*----------------------------------------------------------------------*
***INCLUDE LZMQBA_GUI_WIDGETO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_sen OUTPUT.
  IF gr_subscreen IS NOT INITIAL.
    gr_subscreen->pbo( CHANGING cs_uidata = zmqba_gui_s_wgt_sen_out ).
    CLEAR gr_subscreen.
  ENDIF.
ENDMODULE.

MODULE pbo_swt OUTPUT.
  IF gr_subscreen IS NOT INITIAL.
    gr_subscreen->pbo( CHANGING cs_uidata = zmqba_gui_s_wgt_swt_out ).
    CLEAR gr_subscreen.
  ENDIF.
ENDMODULE.

MODULE pbo_ppl OUTPUT.
  IF gr_subscreen IS NOT INITIAL.
    gr_subscreen->pbo( CHANGING cs_uidata = zmqba_gui_s_wgt_ppl_out ).
    CLEAR gr_subscreen.
  ENDIF.
ENDMODULE.
