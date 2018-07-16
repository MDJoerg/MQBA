class ZCL_APC_WSP_EXT_ZMQBA_GW definition
  public
  inheriting from CL_APC_WSP_EXT_STATELESS_BASE
  final
  create public .

public section.

  methods IF_APC_WSP_EXTENSION~ON_CLOSE
    redefinition .
  methods IF_APC_WSP_EXTENSION~ON_MESSAGE
    redefinition .
  methods IF_APC_WSP_EXTENSION~ON_START
    redefinition .
  methods IF_APC_WSP_EXTENSION~ON_ERROR
    redefinition .
protected section.

  methods GET_REQUEST_FROM_MESSAGE
    importing
      !IR_MSG type ref to IF_APC_WSP_MESSAGE
    returning
      value(RR_MSG) type ref to ZCL_MQBA_APC_MESSAGE .
private section.
ENDCLASS.



CLASS ZCL_APC_WSP_EXT_ZMQBA_GW IMPLEMENTATION.


  METHOD get_request_from_message.

* ----- local data
    DATA: lt_lines   TYPE TABLE OF string.
    DATA: lv_topic   TYPE string.
    DATA: lv_id      TYPE string.
    DATA: lv_payload TYPE string.
    DATA: lv_sender  TYPE string VALUE 'unknown'.
    DATA: lv_context TYPE string VALUE '*'.
    DATA: lv_qos     TYPE string VALUE '0'.
    DATA: lv_retain  TYPE string VALUE '0'.



* ----- check incoming
    DATA(lv_msg) = ir_msg->get_text( ).
    IF lv_msg IS NOT INITIAL AND lv_msg CP 't:*'.

*     split at new line
      SPLIT lv_msg AT cl_abap_char_utilities=>newline INTO TABLE lt_lines.
      IF lt_lines[] IS NOT INITIAL.

*     loop over lines and set fields
        LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<lfs_line>).

          IF <lfs_line> IS NOT INITIAL.
*           check line
            DATA(lv_len) = strlen( <lfs_line> ).
            IF lv_len > 2 AND <lfs_line>+1(1) = ':'.
*             prepare line
              DATA(lv_prefix) = <lfs_line>(1).
              DATA(lv_value)  = <lfs_line>+2.
*             process line
              CASE lv_prefix.
                WHEN 't'. lv_topic   = lv_value.
                WHEN 'p'. lv_payload = lv_value.
                WHEN 'i'. lv_id      = lv_value.
                WHEN 'q'. lv_qos     = lv_value.
                WHEN 'r'. lv_retain  = lv_value.
                WHEN 'c'. lv_context = lv_value.
                WHEN 's'. lv_sender  = lv_value.
                WHEN OTHERS.
              ENDCASE.
            ENDIF.
          ENDIF.
        ENDLOOP.

*       create an apc message object and set data
        DATA(lr_msg) = zcl_mqba_apc_factory=>create_message( ir_msg ).

        lr_msg->set_main_data(
           iv_topic    = lv_topic
           iv_payload  = lv_payload
           iv_id       = lv_id
           iv_context  = lv_context
           iv_sender   = lv_sender
           iv_scope    = zif_mqba_broker=>c_scope_external
           ).

*       return
        rr_msg = lr_msg.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD if_apc_wsp_extension~on_close.
*CALL METHOD SUPER->IF_APC_WSP_EXTENSION~ON_CLOSE
*  EXPORTING
*    I_REASON       =
*    I_CODE         =
*    I_CONTEXT_BASE =
*    .
  ENDMETHOD.


  METHOD if_apc_wsp_extension~on_error.
*CALL METHOD SUPER->IF_APC_WSP_EXTENSION~ON_ERROR
*  EXPORTING
*    I_REASON       =
*    I_CODE         =
*    I_CONTEXT_BASE =
*    .
  ENDMETHOD.


  METHOD if_apc_wsp_extension~on_message.

* ---- local data
    DATA: lv_answer TYPE string.



* ----- PROCESS MESSAGE
    TRY.
* ----- testing issues
        BREAK-POINT ID zmqba_gw.
        DATA(lv_msg_text) = i_message->get_text( ).

* ----- create own apc context
        DATA(lr_context)   = zcl_mqba_apc_factory=>create_context( i_context ).
        DATA(lr_response)  = zcl_mqba_apc_factory=>create_response( i_message_manager ).

        ASSERT ID zmqba_gw
          SUBKEY 'apc_context'
          CONDITION lr_context IS BOUND AND lr_response IS BOUND.

* ----- retrieve the text message
        DATA(lr_request) = get_request_from_message( i_message ).
        IF   lr_request IS INITIAL
          OR lr_request->zif_mqba_request~is_valid( ) EQ abap_false.

          lv_answer = |500 - INVALID MESSAGE|.

          LOG-POINT ID zmqba_gw SUBKEY 'invalid_message_in' FIELDS lv_msg_text.
          BREAK-POINT ID zmqba_gw.

        ELSE.
* ----- set context information
          lr_request->set_msg_context( lr_context ).
          lr_request->set_msg_response( lr_response ).

* ----- forward message to abap message broker
          DATA(lr_broker) = zcl_mqba_factory=>get_broker( lr_request->zif_mqba_request~get_context( ) ).
          IF lr_broker->external_message_arrived( lr_request ) EQ abap_false.
            lv_answer = |500 - ERROR WHILE FORWARDING TO BROKER|.

            DATA(lv_err_msg) = lr_broker->get_last_error( ).

            LOG-POINT ID zmqba_gw SUBKEY 'invalid_message_forwarding' FIELDS lv_msg_text lv_err_msg.

            BREAK-POINT ID zmqba_gw.

          ENDIF.
        ENDIF.

* ----- create the answer
        IF lv_answer IS NOT INITIAL.
          LOG-POINT ID zmqba_gw SUBKEY 'send_answer' FIELDS lv_answer.
          lr_response->zif_mqba_response~post_answer( lv_answer ).
        ENDIF.

      CATCH cx_apc_error
            INTO DATA(lx_apc_error).

        LOG-POINT ID zmqba_gw SUBKEY 'errors_occured' FIELDS lx_apc_error->get_text( ).
        MESSAGE lx_apc_error->get_text( ) TYPE 'E'.
    ENDTRY.

  ENDMETHOD.


  METHOD if_apc_wsp_extension~on_start.

* ------ testing issues
    BREAK-POINT ID zmqba_apc.



* ------ create greeting answer
    TRY.
*       prepare answer text
        DATA(lv_text) = |connected to Message Queue Broker ABAP (MQBA) - Gateway for { sy-sysid }/{ sy-mandt }|.
* append my consumer id
        DATA(lv_session_id) = cl_amc_channel_manager=>get_consumer_session_id( ).
        IF lv_session_id IS NOT INITIAL.
          lv_text = lv_text
                    && zif_mqba_broker=>c_char_newline
                    && |session_id:{ lv_session_id }|.
        ENDIF.

        LOG-POINT ID zmqba_apc SUBKEY 'connected' FIELDS lv_session_id lv_text.

*       send answer
        DATA(lo_message) = i_message_manager->create_message( ).
        lo_message->set_text( lv_text ).
        i_message_manager->send( lo_message ).


*       error handling
      CATCH cx_apc_error
            cx_amc_error
        INTO DATA(lx_apc_error).

        DATA(lv_error) = lx_apc_error->get_text( ).

        LOG-POINT ID zmqba_apc SUBKEY 'error_connect' FIELDS lv_session_id lv_error.

        ASSERT ID zmqba_apc
           SUBKEY 'connect_error'
           FIELDS lv_error
           CONDITION lv_error IS INITIAL.

        MESSAGE lv_error  TYPE 'e'.
    ENDTRY.


* ------- bind to amc channel for outbound messaging
    TRY.
        " bind the default AMC channel to APC WebSocket connection
        DATA(lo_binding) = i_context->get_binding_manager( ).
        lo_binding->bind_amc_message_consumer( i_application_id = zif_mqba_broker=>c_gw_amc_app
                                               i_channel_id     = zif_mqba_broker=>c_gw_amc_chn_messages ).

      CATCH cx_apc_error
        INTO DATA(lo_apc_error).

        lv_error = lx_apc_error->get_text( ).

        LOG-POINT ID zmqba_apc SUBKEY 'error_amc_bind' FIELDS lv_session_id lv_error.

        ASSERT ID zmqba_apc
           SUBKEY 'amc_bind'
           FIELDS lv_error
           CONDITION lv_error IS INITIAL.

        MESSAGE lv_error  TYPE 'e'.


    ENDTRY.


  ENDMETHOD.
ENDCLASS.
