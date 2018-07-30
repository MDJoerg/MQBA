class ZCL_MQBA_GUI_WIDGET definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_GUI_WIDGET .
  interfaces ZIF_MQBA_GUI_SUBSCREEN .

  class-methods CREATE
    importing
      !IV_TYPE type DATA optional
    returning
      value(RR_INSTANCE) type ref to ZCL_MQBA_GUI_WIDGET .
protected section.

  data M_DESCRIPTION type STRING .
  data M_MAX type STRING .
  data M_MIN type STRING .
  data M_CUR type STRING .
  data M_SUBSCRIBE type STRING .
  data M_PUBLISH type STRING .
  data M_CFG_IDX type STRING .
  data M_UNIT type STRING .
  data M_UPDATED type ZMQBA_TIMESTAMP .
  data M_SUBSCREEN_MODE type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data M_SUBSCREEN_PROGRAM type PROGRAM .
  data M_SUBSCREEN_BDYNNR type SYDYNNR .
  data M_SUBSCREEN_CONTAINER type STRING .

  methods PUBLISH
    importing
      !IV_PAYLOAD type DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods GET_PROP_FROM_CFG_STRUC
    importing
      !IS_CFG type DATA
      !IV_NAME type DATA
    changing
      !CV_PROP type DATA .
  methods GET_UPDATED_INFO
    returning
      value(RV_INFO) type STRING .
  methods GET_UI_FIELD
    importing
      !IV_NAME type DATA
      !IV_SUBSCREEN type ABAP_BOOL default ABAP_FALSE
      !IS_UIDATA type DATA
    changing
      !CV_VALUE type DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods SET_UI_FIELD
    importing
      !IV_NAME type DATA
      !IV_VALUE type DATA
      !IV_SUBSCREEN type ABAP_BOOL default ABAP_FALSE
    changing
      !CS_UIDATA type DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods INITIALIZE .
private section.
ENDCLASS.



CLASS ZCL_MQBA_GUI_WIDGET IMPLEMENTATION.


  METHOD create.
* --- local data
    DATA: lv_class TYPE seoclsname VALUE 'ZCL_MQBA_GUI_WIDGET'.

* --- generate class name as suffix or complete class name
    IF iv_type IS NOT INITIAL.
      IF strlen( iv_type ) > 10 AND iv_type CP '*CL*'.
        lv_class = iv_type.
      ELSE.
        lv_class = lv_class && '_' && iv_type.
      ENDIF.
    ENDIF.

* --- create an instance of givem type
    CREATE OBJECT rr_instance TYPE (lv_class).
    rr_instance->initialize( ).

  ENDMETHOD.


  METHOD get_prop_from_cfg_struc.

* ------- local data
    DATA: lv_name TYPE string.

* ------- get component name
    lv_name = iv_name.
    IF m_cfg_idx IS NOT INITIAL.
      lv_name = lv_name && '_' && m_cfg_idx.
    ENDIF.

* ------- assign the component
    ASSIGN COMPONENT lv_name OF STRUCTURE is_cfg TO FIELD-SYMBOL(<lfs_param>).
    IF <lfs_param> IS ASSIGNED.
      cv_prop = <lfs_param>.
    ENDIF.

  ENDMETHOD.


  METHOD get_ui_field.

* ----- local data
    DATA: lv_name TYPE string.

* ----- build name of the ui structure
    lv_name = iv_name.
    IF iv_subscreen EQ abap_false AND m_cfg_idx IS NOT INITIAL.
      lv_name = lv_name && '_' && m_cfg_idx.
    ENDIF.

* ----- get the field
    ASSIGN COMPONENT lv_name OF STRUCTURE is_uidata TO FIELD-SYMBOL(<field>).
    IF <field> IS ASSIGNED.
      cv_value = <field>.
      rv_success = abap_true.
    ELSE.
      rv_success = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD get_updated_info.

* ----- local data
    DATA: lv_now    TYPE zmqba_timestamp.
    DATA: lv_delta  TYPE zmqba_timestamp.
    DATA: lv_unit   TYPE string.
    DATA: lv_value  TYPE i.


* ------ get now and create delta
    GET TIME STAMP FIELD lv_now.
    lv_delta = lv_now - m_updated.

* ----- check for intervals
* not valid
    IF lv_delta < 0.
      rv_info = '???'.
* sek
    ELSEIF lv_delta < 60.
      lv_value = lv_delta.
      lv_unit  = 's'.
* min
    ELSEIF lv_delta < 60 * 60.
      lv_value = lv_delta / 60.
      lv_unit  = 'm'.
* hour
    ELSEIF lv_delta < 60 * 60 * 60.
      lv_value = lv_delta / 60 / 60.
      lv_unit  = 'h'.
* hour
    ELSEIF lv_delta < 60 * 60 * 60 * 24.
      lv_value = lv_delta / 60 / 60 / 24.
      lv_unit  = 'd'.
    ELSE.
* very old
      rv_info = 'very old'.
    ENDIF.

* ------ set result
    IF rv_info IS INITIAL.
      rv_info = |{ lv_value }{ lv_unit }|.
    ENDIF.


  ENDMETHOD.


  method INITIALIZE.
  endmethod.


  METHOD publish.

* ------ local data
    DATA: lv_error  TYPE abap_bool.
    DATA: lv_error_text TYPE string.

* ------ check
    rv_success = abap_false.
    CHECK m_publish IS NOT INITIAL.
    CHECK iv_payload IS NOT INITIAL.

* ------- post
    CALL FUNCTION 'Z_MQBA_API_BROKER_PUBLISH'
      EXPORTING
        iv_topic      = m_publish
        iv_payload    = iv_payload
*       IV_SESSION_ID =
        iv_external   = 'X'
*       IV_CONTEXT    =
*       IT_PROPS      =
      IMPORTING
        ev_error_text = lv_error_text
        ev_error      = lv_error
*       EV_GUID       =
*       EV_SCOPE      =
      .

* ------- success
    IF lv_error EQ abap_false.
      rv_success = abap_true.
    ELSE.
      MESSAGE s006(zmqba) WITH m_publish iv_payload lv_error_text. " error publishing message
    ENDIF.


  ENDMETHOD.


  METHOD set_ui_field.

* ----- local data
    DATA: lv_name TYPE string.

* ----- build name of the ui structure
    lv_name = iv_name.
    IF iv_subscreen EQ abap_false AND m_cfg_idx IS NOT INITIAL.
      lv_name = lv_name && '_' && m_cfg_idx.
    ENDIF.

* ----- get the field
    ASSIGN COMPONENT lv_name OF STRUCTURE cs_uidata TO FIELD-SYMBOL(<field>).
    IF <field> IS ASSIGNED.
      <field> = iv_value.
      rv_success = abap_true.
    ELSE.
      rv_success = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_gui_subscreen~get_container.
    rv_container  = m_subscreen_container.
  ENDMETHOD.


  METHOD zif_mqba_gui_subscreen~get_screen.
    ev_program    = m_subscreen_program.
    ev_dynnr      = m_subscreen_bdynnr.
  ENDMETHOD.


  method ZIF_MQBA_GUI_SUBSCREEN~PAI.
  endmethod.


  METHOD zif_mqba_gui_subscreen~pbo.
    zif_mqba_gui_widget~update_ui( EXPORTING iv_subscreen = abap_true CHANGING cs_uidata = cs_uidata ).
  ENDMETHOD.


  METHOD zif_mqba_gui_subscreen~pbx_before.
    DATA(lv_field) = |({ m_subscreen_program })GR_SUBSCREEN|.
    ASSIGN (lv_field) TO FIELD-SYMBOL(<lfs_field>).
    IF <lfs_field> IS ASSIGNED.
      <lfs_field> = me.
    ENDIF.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~get_cfg_idx.
    ev_idx = m_cfg_idx.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~get_publish_topic.
    rv_topic = m_publish.
  ENDMETHOD.


  method ZIF_MQBA_GUI_WIDGET~GET_SUBSCRIBE_TOPIC.
    rv_topic = m_subscribe.
  endmethod.


  method ZIF_MQBA_GUI_WIDGET~HANDLE_OKCODE.
  endmethod.


  METHOD zif_mqba_gui_widget~handle_payload.
* --- set default to wrong
    rv_handled = abap_false.

* --- check my topic
    IF iv_topic CP m_subscribe.
      zif_mqba_gui_widget~set_cur( iv_payload ).
      rv_handled = abap_true.

      IF iv_updated IS NOT INITIAL.
        m_updated = iv_updated.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_gui_widget~is_subscreen.
    rv_subscreen = COND #( WHEN m_subscreen_mode    EQ abap_true
                            AND m_subscreen_program IS NOT INITIAL
                            AND m_subscreen_bdynnr  IS NOT INITIAL
                           THEN abap_true
                           ELSE abap_false ).
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~set_cfg_idx.
    m_cfg_idx = iv_idx.
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~set_cur.
    GET TIME STAMP FIELD m_updated.
    m_cur = iv_cur.
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~set_description.
    m_description = iv_description.
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~set_from_cfg.

* ---- get known properties from structure with suffix detection
    get_prop_from_cfg_struc( EXPORTING is_cfg  = is_config iv_name = 'DESC'   CHANGING cv_prop = m_description ).
    get_prop_from_cfg_struc( EXPORTING is_cfg  = is_config iv_name = 'TOPS'   CHANGING cv_prop = m_subscribe ).
    get_prop_from_cfg_struc( EXPORTING is_cfg  = is_config iv_name = 'TOPP'   CHANGING cv_prop = m_publish ).
    get_prop_from_cfg_struc( EXPORTING is_cfg  = is_config iv_name = 'MIN'    CHANGING cv_prop = m_min ).
    get_prop_from_cfg_struc( EXPORTING is_cfg  = is_config iv_name = 'MAX'    CHANGING cv_prop = m_max ).
    get_prop_from_cfg_struc( EXPORTING is_cfg  = is_config iv_name = 'CUR'    CHANGING cv_prop = m_cur ).
    get_prop_from_cfg_struc( EXPORTING is_cfg  = is_config iv_name = 'UNIT'   CHANGING cv_prop = m_unit ).

* ----- return myself
    rr_self = me.

  ENDMETHOD.


  METHOD zif_mqba_gui_widget~set_max.
    m_max = iv_max.
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~set_min.
    m_min = iv_min.
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~set_publish_topic.
    m_publish = iv_topic.
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~set_subscreen_mode.

    m_subscreen_mode      = abap_true.
    m_subscreen_container = iv_container.

    IF iv_variant NE '00'.
      m_subscreen_bdynnr+2(2) = iv_variant.
    ENDIF.

    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~set_subscribe_topic.
    m_subscribe = iv_topic.
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~set_unit.
    m_unit = iv_unit.
    rr_self = me.
  ENDMETHOD.


  METHOD zif_mqba_gui_widget~update_ui.

    DEFINE set_field.
      set_ui_field( EXPORTING iv_name = &1  iv_value   = &2 iv_subscreen = iv_subscreen CHANGING cs_uidata = cs_uidata ).
    END-OF-DEFINITION.



    DATA(lv_updated_info) = get_updated_info( ).
    set_field 'UPDATED_INFO'  lv_updated_info.

    set_field 'TITLE'     m_description.
    set_field 'TOPIC_SUB' m_subscribe.
    set_field 'TOPIC_PUB' m_publish.
    set_field 'VALUE'     m_cur.

*    set_ui_field( EXPORTING iv_name = 'UPDATED_INFO'  iv_value   = lv_updated_info CHANGING cs_uidata = cs_uidata ).
*
*
*    set_ui_field( EXPORTING iv_name = 'TITLE'         iv_value   = m_description CHANGING cs_uidata = cs_uidata ).
*    set_ui_field( EXPORTING iv_name = 'TOPIC_SUB'     iv_value   = m_subscribe CHANGING cs_uidata = cs_uidata ).
*    set_ui_field( EXPORTING iv_name = 'VALUE'         iv_value   = m_cur CHANGING cs_uidata = cs_uidata ).

  ENDMETHOD.
ENDCLASS.
