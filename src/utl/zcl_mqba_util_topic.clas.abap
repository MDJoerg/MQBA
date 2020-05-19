class ZCL_MQBA_UTIL_TOPIC definition
  public
  create public .

public section.

  interfaces ZIF_MQBA_UTIL_TOPIC .

  class-methods CREATE
    returning
      value(RR_INSTANCE) type ref to ZIF_MQBA_UTIL_TOPIC .
protected section.

  data MV_MASK type STRING .
  data MT_PARTS type ZMQBA_UTL_T_TOPIC_PARTS .
  data MT_PARAM_VAL type ZMQBA_T_PARAM_VALUE .

  methods PARSE_MASK
    importing
      !IV_MASK type STRING
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods PARSE_TOPIC
    importing
      !IV_TOPIC type STRING
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
private section.
ENDCLASS.



CLASS ZCL_MQBA_UTIL_TOPIC IMPLEMENTATION.


  method CREATE.
    rr_instance = new ZCL_MQBA_UTIL_TOPIC( ).
  endmethod.


  METHOD parse_mask.

* -------- init and check
    rv_success = abap_false.
    CLEAR mt_parts.
    IF iv_mask IS INITIAL
      OR NOT iv_mask CS '/'.
      RETURN.
    ENDIF.


* -------- split and loop
    DATA lt_parts LIKE mt_parts.
    SPLIT iv_mask AT '/' INTO TABLE DATA(lt_mask_parts).
    LOOP AT lt_mask_parts ASSIGNING FIELD-SYMBOL(<lv_part>).
*   append general line
      APPEND INITIAL LINE TO lt_parts ASSIGNING FIELD-SYMBOL(<ls_part>).
      <ls_part>-index = sy-tabix.
      <ls_part>-value = <lv_part>.

*   check for parameters
      IF <lv_part> CS '{'.
        SPLIT <lv_part> AT '{' INTO <ls_part>-prefix_val DATA(lv_rest).
        IF lv_rest IS INITIAL OR NOT lv_rest CS '}'.
          RETURN. " invalid param
        ELSE.
          SPLIT lv_rest AT '}' INTO <ls_part>-param <ls_part>-postfix_val.
          IF <ls_part>-param IS INITIAL.
            RETURN. " invalid param
          ELSE.
*        valid param found --> success and complete part
            rv_success = abap_true.
            <ls_part>-prefix_len = strlen( <ls_part>-prefix_val ).
            <ls_part>-postfix_len = strlen( <ls_part>-postfix_val ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.


* ----------- finally set prepared mask
    IF rv_success EQ abap_true.
      mt_parts = lt_parts.
    ENDIF.

  ENDMETHOD.


  METHOD parse_topic.

* -------- init and check
    rv_success = abap_false.
    CLEAR mt_param_val.
    IF iv_topic IS INITIAL
      OR NOT iv_topic CS '/'.
      RETURN.
    ENDIF.


* -------- split and loop
    DATA lt_values LIKE mt_param_val.
    SPLIT iv_topic AT '/' INTO TABLE DATA(lt_topic_parts).

    LOOP AT lt_topic_parts ASSIGNING FIELD-SYMBOL(<lv_part>).
*   get config for index
      READ TABLE mt_parts ASSIGNING FIELD-SYMBOL(<ls_part>) INDEX sy-tabix.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.

*   if param?
      IF <ls_part>-param IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_parval) = <lv_part>.

*   if prefix expected
      IF <ls_part>-prefix_val IS NOT INITIAL
        AND NOT <lv_part> CP |{ <ls_part>-prefix_val }*|.
        CONTINUE.
      ELSE.
        lv_parval = lv_parval+<ls_part>-prefix_len.
      ENDIF.

*   if postfix expected
      IF <ls_part>-postfix_val IS NOT INITIAL
        AND NOT <lv_part> CP |*{ <ls_part>-postfix_val }|.
        CONTINUE.
      ELSE.
        DATA(lv_len) = strlen( lv_parval ) - <ls_part>-postfix_len.
        lv_parval = lv_parval(lv_len).
      ENDIF.


*   check param alrady given
      READ TABLE lt_values ASSIGNING FIELD-SYMBOL(<ls_value>)
        WITH KEY param = <ls_part>-param.
      IF sy-subrc EQ 0.
        RETURN. " dublette found
      ENDIF.

*   success: add the param
      APPEND INITIAL LINE TO lt_values ASSIGNING <ls_value>.
      <ls_value>-param = <ls_part>-param.
      <ls_value>-value = lv_parval.

      rv_success = abap_true.
    ENDLOOP.


* ----------- finally set prepared mask
    IF rv_success EQ abap_true.
      mt_param_val = lt_values.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqba_util_topic~build_topic.

* ------- check
    IF mt_parts[] IS INITIAL.
      RETURN.
    ENDIF.

* ------- set params
    DATA(lt_param) = it_param.
    IF lt_param[] IS INITIAL.
      lt_param = mt_param_val.
    ENDIF.

    IF lt_param[] IS INITIAL.
      RETURN.
    ENDIF.

* ------- build topic
    DATA(lv_topic) = ||.
    LOOP AT mt_parts ASSIGNING FIELD-SYMBOL(<ls_part>).

*   default part
      DATA(lv_part) = <ls_part>-value.

*   is param?
      IF <ls_part>-param IS NOT INITIAL.
        READ TABLE lt_param ASSIGNING FIELD-SYMBOL(<ls_param>)
          WITH KEY param = <ls_part>-param.
        IF sy-subrc NE 0.
          RETURN. " missing param
        ELSE.
          lv_part = |{ <ls_part>-prefix_val }{ <ls_param>-value }{ <ls_part>-postfix_val }|.
        ENDIF.
      ENDIF.

*   set part
      IF <ls_part>-index = 1.
        lv_topic = lv_part.
      ELSE.
        lv_topic = |{ lv_topic }/{ lv_part }|.
      ENDIF.
    ENDLOOP.

* -------- set topic
    rv_topic = lv_topic.

  ENDMETHOD.


  method ZIF_MQBA_UTIL_TOPIC~GET_MASK_PARTS.
    rt_parts = mt_parts.
  endmethod.


  METHOD zif_mqba_util_topic~get_parameter.
    READ TABLE mt_param_val ASSIGNING FIELD-SYMBOL(<ls_param>)
      WITH KEY param = iv_param.
    IF sy-subrc EQ 0.
      rv_value = <ls_param>-value.
    ENDIF.
  ENDMETHOD.


  METHOD zif_mqba_util_topic~get_parameters.
    LOOP AT mt_parts ASSIGNING FIELD-SYMBOL(<ls_part>)
      WHERE param NE space.
      APPEND INITIAL LINE TO rt_params ASSIGNING FIELD-SYMBOL(<lv_param>).
      <lv_param> = <ls_part>-param.
    ENDLOOP.
  ENDMETHOD.


  method ZIF_MQBA_UTIL_TOPIC~GET_PARAMETER_VALUES.
    rt_param_values = mt_param_val.
  endmethod.


  METHOD zif_mqba_util_topic~get_topic_mask.
    rv_mask = mv_mask.
  ENDMETHOD.


  method ZIF_MQBA_UTIL_TOPIC~RESET.
    clear: mv_mask,
           mt_parts,
           mt_param_val.
  endmethod.


  method ZIF_MQBA_UTIL_TOPIC~RESET_PARAMETER.
    clear: mt_param_val.
  endmethod.


  METHOD zif_mqba_util_topic~set_parameter.
    READ TABLE mt_param_val ASSIGNING FIELD-SYMBOL(<ls_param>)
      WITH KEY param = iv_param.
    IF sy-subrc NE 0.
      APPEND INITIAL LINE TO mt_param_val ASSIGNING <ls_param>.
      <ls_param>-param = iv_param.
    ENDIF.
    <ls_param>-value = iv_value.
  ENDMETHOD.


  METHOD zif_mqba_util_topic~set_parameter_values.
    mt_param_val = it_param_values.
  ENDMETHOD.


  METHOD zif_mqba_util_topic~set_topic.

* ------ init and check
    rv_success = abap_false.
    IF iv_topic IS INITIAL
      OR mt_parts[] IS INITIAL.
      RETURN.
    ENDIF.

* ------- parse
    rv_success = parse_topic( iv_topic ).

  ENDMETHOD.


  METHOD zif_mqba_util_topic~set_topic_mask.
    rv_success = abap_false.
    IF parse_mask( CONV string( iv_mask ) ) EQ abap_true.
      mv_mask = iv_mask.
      rv_success = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
