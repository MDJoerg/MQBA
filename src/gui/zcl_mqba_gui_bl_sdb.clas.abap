class ZCL_MQBA_GUI_BL_SDB definition
  public
  inheriting from ZCL_MQBA_GUI_BL
  create public

  global friends ZCL_MQBA_GUI_BL .

public section.

  methods ZIF_MQBA_GUI_BL~COLLECT_PARAMS
    redefinition .
  methods ZIF_MQBA_GUI_BL~DESTROY
    redefinition .
  methods ZIF_MQBA_GUI_BL~GET_SUBSCREENS
    redefinition .
  methods ZIF_MQBA_GUI_BL~PBO
    redefinition .
  methods HANDLE_OKCODE
    redefinition .
protected section.

  data M_LISTENER type ref to ZIF_MQBA_GUI_MSG_LISTENER .
  data M_UIDATA type ZMQBA_GUI_S_SDB_UI .
  data M_WIDGETS type ref to ZIF_MQBA_GUI_WIDGET_HOLDER .
  data M_CONFIG type ZMQBA_GUI_S_SDB_CFG .

  methods INIT_WIDGETS .
  methods REPAINT .

  methods ON_FIRST_PBO
    redefinition .
private section.

  methods ON_MSG_ARRIVED
    for event ON_MSG_ARRIVED of ZIF_MQBA_GUI_MSG_LISTENER
    importing
      !IT_MSG .
ENDCLASS.



CLASS ZCL_MQBA_GUI_BL_SDB IMPLEMENTATION.


  METHOD handle_okcode.

* ------ init and check
    DATA(lv_okcode) = iv_okcode.

* ------ check for widget suffix
    IF lv_okcode IS NOT INITIAL.
      IF m_widgets IS NOT INITIAL.
        DO m_widgets->get_count( ) TIMES.
          DATA(lr_widget)   = m_widgets->get_widget( sy-index ).
          DATA(lv_cfg_idx)  = lr_widget->get_cfg_idx( ).
          DATA(lv_check)    = '*_' && lv_cfg_idx.
          IF iv_okcode CP lv_check.

          ENDIF.
        ENDDO.
      ENDIF.
    ENDIF.

* ------ call super
    rv_next_dynnr = super->handle_okcode( iv_okcode ).

  ENDMETHOD.


  METHOD init_widgets.

* ------ create a widget holder
    m_widgets = zcl_mqba_gui_factory=>create_widget_holder( ).

* ------ create 3 simple sensor widgets
    m_widgets->add( zcl_mqba_gui_factory=>create_widget( zif_mqba_gui_widget=>c_type_sensor
    )->set_cfg_idx( 'S1' )->set_from_cfg( m_config )->set_subscreen_mode( 'SUBSCR1' ) ).

    m_widgets->add( zcl_mqba_gui_factory=>create_widget( zif_mqba_gui_widget=>c_type_sensor
    )->set_cfg_idx( 'S2' )->set_from_cfg( m_config )->set_subscreen_mode( 'SUBSCR2' ) ).

    m_widgets->add( zcl_mqba_gui_factory=>create_widget( zif_mqba_gui_widget=>c_type_sensor
    )->set_cfg_idx( 'S3' )->set_from_cfg( m_config )->set_subscreen_mode( 'SUBSCR3' ) ).

* ------ create 1 switch
    m_widgets->add( zcl_mqba_gui_factory=>create_widget( zif_mqba_gui_widget=>c_type_switch
    )->set_cfg_idx( 'B1' )->set_from_cfg( m_config )->set_subscreen_mode( 'SUBSCR4' ) ).

* ------ create 1 publish panel
    m_widgets->add( zcl_mqba_gui_factory=>create_widget( zif_mqba_gui_widget=>c_type_pubpanel
    )->set_cfg_idx( 'P1' )->set_from_cfg( m_config )->set_subscreen_mode( 'SUBSCR5' ) ).


  ENDMETHOD.


  METHOD on_first_pbo.

* ------ local data
    DATA: ls_memory TYPE zmqba_api_s_brk_msg.


* ------ init widgets
    init_widgets( ).


* ------ simulate a inital load
    CALL FUNCTION 'Z_MQBA_API_BROKER_GET_MEMORY'
      IMPORTING
        es_data = ls_memory.

    IF ls_memory IS NOT INITIAL.
      on_msg_arrived( ls_memory-msg ).
    ENDIF.



* ================ LISTENER
* ------ create new listener
    m_listener = zcl_mqba_gui_factory=>create_listener( ).

* ------ bind event handler
    SET HANDLER on_msg_arrived FOR m_listener.

* ------ subscribe to topics
    IF m_widgets IS NOT INITIAL AND m_widgets->get_count( ) GT 0.
      DO m_widgets->get_count( ) TIMES.
        DATA(lr_widget) = m_widgets->get_widget( sy-index ).
        DATA(lv_widsub) = lr_widget->get_subscribe_topic( ).
        IF lv_widsub IS NOT INITIAL.
          m_listener->subscribe_to( lv_widsub ).
        ENDIF.
      ENDDO.
    ENDIF.

* ------ subscribe to other topics
    m_listener->subscribe_to( '*' ).


* ------ start background listening
    m_listener->start( ).

  ENDMETHOD.


  METHOD on_msg_arrived.

* ----- local data
    DATA: lv_handled TYPE i.

* ----- check widgets
    IF m_widgets IS NOT INITIAL
     AND m_widgets->get_count( ) GT 0.
      LOOP AT it_msg INTO DATA(ls_msg).
        lv_handled = lv_handled + m_widgets->handle_payload(
            iv_topic         = ls_msg-topic
            iv_payload       = ls_msg-payload
            iv_updated       = ls_msg-updated ).
      ENDLOOP.

    ENDIF.


* ----- set update avaiable
    IF lv_handled GT 0.
      repaint( ).
      set_new_uidata( ).
    ENDIF.

  ENDMETHOD.


  METHOD repaint.

* loop widgets and call ui update
    IF m_widgets IS NOT INITIAL AND m_widgets->get_count( ) GT 0.
      DO m_widgets->get_count( ) TIMES.
        DATA(lr_widget) = m_widgets->get_widget( sy-index ).
        lr_widget->update_ui( CHANGING cs_uidata = m_uidata ).
      ENDDO.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_gui_bl~collect_params.

* --- call super
    rv_success = super->zif_mqba_gui_bl~collect_params( ).
    CHECK rv_success = abap_true.

* --- get cfg structure from collected params
    IF m_params IS NOT INITIAL.
      m_params->fill_structure( CHANGING cs_struc = m_config ).
    ENDIF.


  ENDMETHOD.


  METHOD zif_mqba_gui_bl~destroy.

* ------- destroy listener
    IF m_listener IS NOT INITIAL.
      m_listener->destroy( ).
      CLEAR m_listener.
    ENDIF.

* ------- call super
    super->zif_mqba_gui_bl~destroy( ).

  ENDMETHOD.


  METHOD zif_mqba_gui_bl~get_subscreens.

* ----- loop subscreens
    IF m_widgets IS NOT INITIAL AND m_widgets->get_count( ) GT 0.
      DO m_widgets->get_count( ) TIMES.
        DATA(lr_widget) = m_widgets->get_widget( sy-index ).
        IF lr_widget IS NOT INITIAL AND lr_widget->is_subscreen( ).
          DATA(lr_subscreen) = CAST zif_mqba_gui_subscreen( lr_widget ).
          APPEND lr_subscreen TO rt_subscreen.
        ENDIF.
      ENDDO.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_gui_bl~pbo.

* ----- call super
    CALL METHOD super->zif_mqba_gui_bl~pbo
      IMPORTING
        et_excl_fcodes = et_excl_fcodes
        ev_text        = ev_text
        ev_titlebar    = ev_titlebar
        ev_status      = ev_status
      CHANGING
        cv_okcode      = cv_okcode
        cs_uidata      = cs_uidata.

  ENDMETHOD.
ENDCLASS.
