class ZCL_APC_WSP_EXT_ZMQBA_INT definition
  public
  inheriting from CL_APC_WSP_EXT_STATELESS_BASE
  final
  create public .

public section.

  methods IF_APC_WSP_EXTENSION~ON_START
    redefinition .
  methods IF_APC_WSP_EXTENSION~ON_MESSAGE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_APC_WSP_EXT_ZMQBA_INT IMPLEMENTATION.


  METHOD if_apc_wsp_extension~on_message.


    DATA: lo_producer       TYPE REF TO if_amc_message_producer_pcp.
    DATA: lo_pcp            TYPE REF TO if_ac_message_type_pcp.
    DATA: lr_msg            TYPE REF TO zcl_mqba_int_message.


    TRY.



        lo_producer ?= cl_amc_channel_manager=>create_message_producer( i_application_id = zif_mqba_broker=>c_int_amc_app
                                                                            i_channel_id     = zif_mqba_broker=>c_int_amc_chn_messages ).
        lr_msg ?= zcl_mqba_factory=>create_message( ).

        lr_msg->set_scope( zif_mqba_broker=>c_scope_external ).

        lr_msg->set_data_from_apc_msg( i_message ).

        lo_pcp ?= lr_msg->create_pcp_message( ).

        lo_producer->send( lo_pcp ).

        "Error Handling will be discussed in a different example

      CATCH cx_apc_error
            cx_ac_message_type_pcp_error.

    ENDTRY.
  ENDMETHOD.


  METHOD if_apc_wsp_extension~on_start.

    TRY.
* ------send the message on WebSocket connection
* prepare the open answer
        DATA(lv_text) = |message:connected to Message Queue Broker ABAP (MQBA) - Internal for { sy-sysid }/{ sy-mandt }|.
* append my consumer id
        DATA(lv_consumer_id) = cl_amc_channel_manager=>get_consumer_session_id( ).
        IF lv_consumer_id IS NOT INITIAL.
          lv_text = lv_text
                    && cl_abap_char_utilities=>newline
                    && |consumer_id:{ lv_consumer_id }|.
        ENDIF.
* create answer message, set text and send
        DATA(lo_message) = i_message_manager->create_message( ).
        lo_message->set_text( lv_text ).
        i_message_manager->send( lo_message ).
* error handling
      CATCH cx_apc_error INTO DATA(lx_apc_error).
        MESSAGE lx_apc_error->get_text( ) TYPE 'e'.
    ENDTRY.

* bind to amc channel
    TRY.
        " bind the default AMC channel to APC WebSocket connection
        DATA(lo_binding) = i_context->get_binding_manager( ).
        lo_binding->bind_amc_message_consumer( i_application_id = zif_mqba_broker=>c_int_amc_app
                                               i_channel_id     = zif_mqba_broker=>c_int_amc_chn_messages ).

      CATCH cx_apc_error INTO DATA(lo_apc_error).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
