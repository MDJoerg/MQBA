*&---------------------------------------------------------------------*
*& Report ZMQBA_TEST_SUBSCRIBE
*&---------------------------------------------------------------------*
*& copied and changed from demo_receive_amc
*&---------------------------------------------------------------------*
REPORT zmqba_test_subscribe.

CLASS amc_demo DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS main.
ENDCLASS.



CLASS amc_demo IMPLEMENTATION.
  METHOD main.

* ------ local data
    DATA: lv_topic   TYPE string.
    DATA: lv_time    TYPE i VALUE 5.
    DATA: lv_context TYPE string.
    DATA: lt_topic TYPE TABLE OF string.


* ------ create mqba consumer api
*   create a handler
    DATA(lr_consumer) = zcl_mqba_factory=>get_consumer( ).
*   get my id
    DATA(lv_consumer_id) = lr_consumer->get_consumer_id( ).


* ------ input interface
    DATA(in) = cl_demo_input=>new( ).

    TRY.
        in->add_text( `Session id: ` && lv_consumer_id ).
        in->add_field( EXPORTING text = 'Subscribe to Topic' CHANGING field = lv_topic ).
        in->add_field( EXPORTING text = 'Filter context' CHANGING field = lv_context ).
        in->add_field( EXPORTING text = 'Waiting time' CHANGING field = lv_time ).
        in->request( ).


      CATCH cx_amc_error INTO DATA(id_exc).
        cl_demo_output=>display( id_exc->get_text( ) ).
    ENDTRY.


* ------- call mqba consumer api
*   subscribe to topics
    IF lv_topic IS NOT INITIAL.
      IF lv_topic CS ';'.
        SPLIT lv_topic AT ';' INTO TABLE lt_topic.
        LOOP AT lt_topic INTO lv_topic.
          lr_consumer->subscribe( lv_topic ).
        ENDLOOP.
      ELSE.
        lr_consumer->subscribe( lv_topic ). " no split
      ENDIF.
    ENDIF.

*   filter context
    IF lv_context IS NOT INITIAL.
      lr_consumer->set_context_filter( lv_context ).
    ENDIF.

*   wait now
    IF lr_consumer->wait_for_messages( lv_time ) EQ abap_true.
* -----   output success
*   local data
      DATA lt_fields TYPE pcp_fields.
      TRY.
*   get pcp data
          DATA(lr_pcp) = lr_consumer->get_message_pcp( ).
          lr_pcp->get_fields( CHANGING c_fields = lt_fields ).
          DATA(lv_payload) = lr_pcp->get_text( ).
*   output window
          DATA(out) = cl_demo_output=>new( ).
*   insert content
          IF lt_fields IS NOT INITIAL OR
             lv_payload   IS NOT INITIAL.
            out->next_section( 'Push Channel Protocol (PCP)'
              )->write( lt_fields
              )->write_html( lv_payload ).
          ENDIF.
*   display
          out->display( ).

*   errors
        CATCH cx_ac_message_type_pcp_error INTO DATA(pcp_exc).
          cl_demo_output=>display( pcp_exc->get_text( ) ).
      ENDTRY.

    ELSE.
* ------ output error
      cl_demo_output=>display( lr_consumer->get_error_text( ) ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  amc_demo=>main( ).
