*&---------------------------------------------------------------------*
*& Report ZMQBA_TEST_TOPIC_CONFIG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmqba_test_topic_config NO STANDARD PAGE HEADING.

PARAMETERS: p_topic TYPE zmqba_topic OBLIGATORY.

START-OF-SELECTION.

* init broker memory api (dummy)
  DATA(lr_bl) = NEW zcl_mqba_shm_data_root( ).


* check as gateway inbound message
  WRITE: / 'Gateway Inbound:'.
  IF lr_bl->check_valid_msg_gwi( p_topic ) EQ abap_true.
    WRITE: 'allowed'.
  ELSE.
    WRITE: 'forbidden'.
  ENDIF.


* cleanup
  CLEAR lr_bl.
  WRITE: / 'Finished.'.
