*&---------------------------------------------------------------------*
*& Report ZMQBA_TEST_PUBLISH
*&---------------------------------------------------------------------*
*& copied and changed from demo_send_amc
*&---------------------------------------------------------------------*
REPORT zmqba_test_publish.

CLASS test DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS main.
ENDCLASS.

CLASS test IMPLEMENTATION.
  METHOD main.

* ---- internal vars
    DATA topic          TYPE string.
    DATA payload        TYPE string.
    DATA context        TYPE string.
    DATA field1         TYPE string VALUE 'Field1'.
    DATA value1         TYPE string VALUE 'Value1'.
    DATA field2         TYPE string VALUE 'Field2'.
    DATA value2         TYPE string VALUE 'Value2'.
    DATA ext_flag       TYPE abap_bool.
    DATA ext_brkid      TYPE string.
    DATA session_id     TYPE amc_consumer_session_id.

* ---- set example data
    topic   = |/{ sy-sysid }CLNT{ sy-mandt }/{ sy-uname }/{ sy-uzeit }|.
    payload = |{ sy-uzeit }|.

* ---- input screen
    cl_demo_input=>new(
      )->add_field( EXPORTING text = 'Topic' CHANGING field = topic
      )->add_field( EXPORTING text = 'Payload' CHANGING  field = payload
      )->add_line(
      )->add_field( EXPORTING text = 'Context' CHANGING field = context
      )->add_line(
      )->add_field( EXPORTING text = 'Field1' CHANGING field = value1
      )->add_field( EXPORTING text = 'Field2' CHANGING field = value2
      )->add_line(
      )->add_field( EXPORTING text  = 'as external message' as_checkbox = abap_true CHANGING  field = ext_flag
      )->add_field( EXPORTING text  = 'external broker id' CHANGING field = ext_brkid
      )->add_field( EXPORTING text  = 'private with session id' CHANGING  field = session_id
      )->request( ).

* ------- publish via mqba api
* get a message producer
    DATA(lr_producer) = zcl_mqba_factory=>get_producer( ).
* set the main fields
    lr_producer->set_topic( topic )->set_payload( payload )->set_consumer_id( session_id ).
* set context
    IF context IS NOT INITIAL.
      lr_producer->set_context( context ).
    ENDIF.
* distribute to external broker?
    IF ext_flag = abap_true.
      lr_producer->set_external( ).
      IF ext_brkid IS NOT INITIAL.
        lr_producer->set_external_broker( ext_brkid ).
      ENDIF.
    ENDIF.
* set additional fields
    lr_producer->set_field( iv_name = 'field1' iv_value = value1 ).
    lr_producer->set_field( iv_name = 'field2' iv_value = value2 ).
* publish now
    IF lr_producer->publish( ) EQ abap_false.
* errors occured
      cl_demo_output=>display( lr_producer->get_error_text( ) ).
    ELSE.
* success !
      DATA(lr_msg) = lr_producer->get_message( ).
      cl_demo_output=>display( |Message published to Broker { ext_brkid } with internal message id { lr_msg->get_guid( ) } and scope { lr_msg->get_scope( ) }| ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.



START-OF-SELECTION.
  test=>main( ).
