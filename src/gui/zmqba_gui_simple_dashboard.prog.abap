*&---------------------------------------------------------------------*
*& Report ZMQBA_GUI_SIMPLE_DASHBOARD
*&---------------------------------------------------------------------*
*& alpha!
*&---------------------------------------------------------------------*
REPORT zmqba_gui_simple_dashboard.

* ================ INTERFACE
TABLES: zmqba_gui_s_sdb_cfg.
* ----------- 3x sensors
SELECTION-SCREEN: ULINE.
PARAMETERS: desc_s1   LIKE zmqba_gui_s_sdb_cfg-desc_s1.
PARAMETERS: unit_s1   LIKE zmqba_gui_s_sdb_cfg-unit_s1.
PARAMETERS: tops_s1   LIKE zmqba_gui_s_sdb_cfg-tops_s1.
PARAMETERS: topp_s1   LIKE zmqba_gui_s_sdb_cfg-topp_s1.
SELECTION-SCREEN: ULINE.
PARAMETERS: desc_s2   LIKE zmqba_gui_s_sdb_cfg-desc_s2.
PARAMETERS: unit_s2   LIKE zmqba_gui_s_sdb_cfg-unit_s2.
PARAMETERS: tops_s2   LIKE zmqba_gui_s_sdb_cfg-tops_s2.
PARAMETERS: topp_s2   LIKE zmqba_gui_s_sdb_cfg-topp_s2.
SELECTION-SCREEN: ULINE.
PARAMETERS: desc_s3   LIKE zmqba_gui_s_sdb_cfg-desc_s3.
PARAMETERS: unit_s3   LIKE zmqba_gui_s_sdb_cfg-unit_s3.
PARAMETERS: tops_s3   LIKE zmqba_gui_s_sdb_cfg-tops_s3.
PARAMETERS: topp_s3   LIKE zmqba_gui_s_sdb_cfg-topp_s3.
SELECTION-SCREEN: ULINE.
PARAMETERS: desc_b1   LIKE zmqba_gui_s_sdb_cfg-desc_b1.
PARAMETERS: tops_b1   LIKE zmqba_gui_s_sdb_cfg-tops_b1.
PARAMETERS: topp_b1   LIKE zmqba_gui_s_sdb_cfg-topp_b1.
PARAMETERS: valon_b1  LIKE zmqba_gui_s_sdb_cfg-valon_b1.
PARAMETERS: valof_b1  LIKE zmqba_gui_s_sdb_cfg-valof_b1.
SELECTION-SCREEN: ULINE.
PARAMETERS: desc_p1   LIKE zmqba_gui_s_sdb_cfg-desc_p1.
PARAMETERS: tops_p1   LIKE zmqba_gui_s_sdb_cfg-tops_p1.
PARAMETERS: topp_p1   LIKE zmqba_gui_s_sdb_cfg-topp_p1.


* ------ data definitions
TABLES: zmqba_gui_s_sdb_ui.
DATA: gr_bl       TYPE REF TO zif_mqba_gui_bl.
DATA: gv_okcode   TYPE syucomm.
FIELD-SYMBOLS: <uidata>.

* subscreen vars
DATA: gv_subscr1_repid TYPE syrepid.
DATA: gv_subscr1_dynnr TYPE sydynnr.
DATA: gv_subscr2_repid TYPE syrepid.
DATA: gv_subscr2_dynnr TYPE sydynnr.
DATA: gv_subscr3_repid TYPE syrepid.
DATA: gv_subscr3_dynnr TYPE sydynnr.
DATA: gv_subscr4_repid TYPE syrepid.
DATA: gv_subscr4_dynnr TYPE sydynnr.
DATA: gv_subscr5_repid TYPE syrepid.
DATA: gv_subscr5_dynnr TYPE sydynnr.


INITIALIZATION.

  gr_bl = NEW zcl_mqba_gui_bl_sdb( ).


START-OF-SELECTION.



* ------ catch params
  IF gr_bl->collect_params( ) EQ abap_false.
    EXIT.
  ENDIF.




* ------- initialize business logic
  ASSIGN zmqba_gui_s_sdb_ui TO <uidata>.


* ------- open screen
  CALL SCREEN 2000.

END-OF-SELECTION.

* ------- destroy all
  gr_bl->destroy( ).

*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2000 OUTPUT.
* ----- call business logic
  gr_bl->pbo(
    IMPORTING
      et_excl_fcodes = DATA(lt_excluded)
      ev_titlebar    = DATA(lv_titlebar)
      ev_status      = DATA(lv_status)
      ev_text        = DATA(lv_text)
    CHANGING
      cv_okcode = gv_okcode
      cs_uidata = <uidata>
  ).

* ----- set classic features
  SET PF-STATUS lv_status EXCLUDING lt_excluded.
  SET TITLEBAR lv_titlebar WITH lv_text.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2000 INPUT.
* ---- call business logic
  gr_bl->pai(  IMPORTING
                  ev_next_dynnr = DATA(lv_next)
               CHANGING
                  cv_okcode = gv_okcode
                  cs_uidata = <uidata>
               ).
* --- bind to classic
  IF sy-dynnr NE lv_next.
    SET SCREEN lv_next.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  SUBSCREEN_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0172   text
*----------------------------------------------------------------------*
FORM subscreen_pbo  USING    VALUE(p_container).

* ---- get subscreen bound to container
  DATA(lr_subscreen) = gr_bl->get_subscreen( p_container ).
  IF lr_subscreen IS NOT INITIAL.
*  get access to variables
    DATA(lv_repid) = |gv_{ p_container }_repid|.
    ASSIGN (lv_repid) TO FIELD-SYMBOL(<lfs_repid>).
    DATA(lv_dynnr) = |gv_{ p_container }_dynnr|.
    ASSIGN (lv_dynnr) TO  FIELD-SYMBOL(<lfs_dynnr>).
*  get assigned subscreen
    lr_subscreen->get_screen( IMPORTING ev_program = <lfs_repid> ev_dynnr = <lfs_dynnr> ).
*  trigger pbx event
    lr_subscreen->pbx_before( ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SUBSCREEN_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0233   text
*----------------------------------------------------------------------*
FORM subscreen_pai  USING    VALUE(p_container).

* ---- get subscreen bound to container
  DATA(lr_subscreen) = gr_bl->get_subscreen( p_container ).
  IF lr_subscreen IS NOT INITIAL.
    lr_subscreen->pbx_before( ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  SUBSCR1_PBO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE subscr1_pbo OUTPUT.
  PERFORM subscreen_pbo USING 'SUBSCR1'.
ENDMODULE.

MODULE subscr2_pbo OUTPUT.
  PERFORM subscreen_pbo USING 'SUBSCR2'.
ENDMODULE.

MODULE subscr3_pbo OUTPUT.
  PERFORM subscreen_pbo USING 'SUBSCR3'.
ENDMODULE.

MODULE subscr4_pbo OUTPUT.
  PERFORM subscreen_pbo USING 'SUBSCR4'.
ENDMODULE.


MODULE subscr5_pbo OUTPUT.
  PERFORM subscreen_pbo USING 'SUBSCR5'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SUBSCR1_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE subscr1_pai INPUT.
  PERFORM subscreen_pai USING 'SUBSCR1'.
ENDMODULE.

MODULE subscr2_pai INPUT.
  PERFORM subscreen_pai USING 'SUBSCR2'.
ENDMODULE.

MODULE subscr3_pai INPUT.
  PERFORM subscreen_pai USING 'SUBSCR3'.
ENDMODULE.

MODULE subscr4_pai INPUT.
  PERFORM subscreen_pai USING 'SUBSCR4'.
ENDMODULE.

MODULE subscr5_pai INPUT.
  PERFORM subscreen_pai USING 'SUBSCR5'.
ENDMODULE.
