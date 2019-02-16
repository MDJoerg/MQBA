INTERFACE zif_mqba_api_mqtt_proxy
  PUBLIC .


  CONSTANTS c_state_not_initialized TYPE string VALUE 'notinitialized' ##NO_TEXT.
  CONSTANTS c_state_connecting TYPE string VALUE 'connecting' ##NO_TEXT.
  CONSTANTS c_state_connected TYPE string VALUE 'connected' ##NO_TEXT.
  CONSTANTS c_state_disconnecting TYPE string VALUE 'disconnecting' ##NO_TEXT.
  CONSTANTS c_state_disconnected TYPE string VALUE 'disconnected' ##NO_TEXT.
  CONSTANTS c_state_unknown TYPE string VALUE 'unknown' ##NO_TEXT.
  CONSTANTS c_state_error TYPE string VALUE 'error' ##NO_TEXT.

  METHODS connect
    RETURNING
      VALUE(rv_success) TYPE abap_bool .
  METHODS disconnect
    RETURNING
      VALUE(rv_success) TYPE abap_bool .
  METHODS reconnect
    RETURNING
      VALUE(rv_success) TYPE abap_bool .
  METHODS is_connected
    RETURNING
      VALUE(rv_success) TYPE abap_bool .
  METHODS set_config
    IMPORTING
      !ir_cfg           TYPE REF TO zif_mqba_cfg_broker
    RETURNING
      VALUE(rv_success) TYPE abap_bool .
  METHODS set_config_apc
    IMPORTING
      !is_apc        TYPE zmqba_api_s_apc_conn_opt
    RETURNING
      VALUE(rr_self) TYPE REF TO zif_mqba_api_mqtt_proxy .
  METHODS set_client_id
    IMPORTING
      !iv_client_id  TYPE data
    RETURNING
      VALUE(rr_self) TYPE REF TO zif_mqba_api_mqtt_proxy .
  METHODS set_last_will
    IMPORTING
      !iv_topic      TYPE data
      !iv_payload    TYPE data
      !iv_qos        TYPE zmqba_mqtt_qos DEFAULT 0
      !iv_retain     TYPE zmqba_mqtt_retain DEFAULT abap_false
    RETURNING
      VALUE(rr_self) TYPE REF TO zif_mqba_api_mqtt_proxy .
  METHODS get_error
    RETURNING
      VALUE(rv_error) TYPE i .
  METHODS get_error_text
    RETURNING
      VALUE(rv_error) TYPE string .
  METHODS is_error
    RETURNING
      VALUE(rv_error) TYPE abap_bool .
  METHODS get_received_messages
    IMPORTING
      !iv_delete    TYPE abap_bool DEFAULT abap_true
    RETURNING
      VALUE(rt_msg) TYPE zmqba_api_t_ebr_msg .
  METHODS subscribe_to
    IMPORTING
      !iv_topic         TYPE data
      !iv_use_prefix    TYPE abap_bool DEFAULT abap_true
      !iv_qos           TYPE zmqba_mqtt_qos DEFAULT 0
    RETURNING
      VALUE(rv_success) TYPE abap_bool .
  METHODS destroy .
  METHODS set_callback_new_msg
    IMPORTING
      !ir_callback   TYPE REF TO zif_mqba_callback_new_msg OPTIONAL
    RETURNING
      VALUE(rr_self) TYPE REF TO zif_mqba_api_mqtt_proxy .
  METHODS publish
    IMPORTING
      !iv_topic         TYPE string
      !iv_payload       TYPE string
      !iv_qos           TYPE i DEFAULT 0
      !iv_retain        TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(rv_success) TYPE abap_bool .
  METHODS get_client_id
    RETURNING
      VALUE(rv_client_id) TYPE string .
  METHODS get_client_state
    RETURNING
      VALUE(rv_state) TYPE string .
ENDINTERFACE.
