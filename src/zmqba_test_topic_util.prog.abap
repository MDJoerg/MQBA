*&---------------------------------------------------------------------*
*& Report ZMQBA_TEST_TOPIC_UTIL
*&---------------------------------------------------------------------*
*& test program for topic util
*&---------------------------------------------------------------------*
REPORT zmqba_test_topic_util NO STANDARD PAGE HEADING.

PARAMETERS: p_tmask TYPE ZMQBA_TOPIC_MASK LOWER CASE OBLIGATORY
                    DEFAULT '/some/prefix/{thingID}/sensor{sensorID}/{command}'.
PARAMETERS: p_topic TYPE ZMQBA_TOPIC LOWER CASE
                    DEFAULT '/some/prefix/12345/sensorTemp001/state'.

INITIALIZATION.

* -------- init tools
  DATA(lr_util) = zcl_mqba_factory=>create_util_topic( ).


START-OF-SELECTION.


* =================== MASK FEATURES
* -------- set mask
  IF lr_util->set_topic_mask( p_tmask ) EQ abap_false.
    WRITE: / |wrong topic mask?!: { p_tmask }|.
    RETURN.
  ELSE.
    WRITE: / |topic mask { p_tmask } activated.|.
  ENDIF.


* ------- get topic parts
  DATA(lt_parts) = lr_util->get_mask_parts( ).
  IF lt_parts[] IS NOT INITIAL.
    SKIP.
    WRITE / |Detected parts of mask:|.
    LOOP AT lt_parts ASSIGNING FIELD-SYMBOL(<ls_part>).
      WRITE: / <ls_part>-index,
               <ls_part>-value,
               <ls_part>-param.
    ENDLOOP.
  ENDIF.

* ------- get availabel parameter
  DATA(lt_params) = lr_util->get_parameters( ).
  IF lt_params[] IS NOT INITIAL.
    SKIP.
    WRITE / |Detected parameters of mask:|.
    LOOP AT lt_params ASSIGNING FIELD-SYMBOL(<lv_param>).
      WRITE: / sy-tabix,
               <lv_param>.
    ENDLOOP.
  ENDIF.


* ================== PARSE TOPIC FEATURE
* set topic
  IF p_topic IS NOT INITIAL.
    IF lr_util->set_topic( p_topic ) EQ abap_false.
      WRITE: / |Set topic failed: { p_topic }|.
    ELSE.
* get detected params
      SKIP.
      WRITE: / |Topic set: { p_topic }|.
      DATA(lt_parval) = lr_util->get_parameter_values( ).
      IF lt_parval[] IS NOT INITIAL.
        SKIP.
        WRITE: / |Detected Parameter Values:|.
        LOOP AT lt_parval ASSIGNING FIELD-SYMBOL(<ls_parval>).
          WRITE: / |{ <ls_parval>-param } = { <ls_parval>-value }|.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.


* ================== BUILD TOPIC FEATURE
  DATA(lv_created_topic) = lr_util->build_topic( ).
  SKIP.
  WRITE: / |created topic: { lv_created_topic }|.
