"! abapGit general error
class ZCX_MQBA_EXCEPTION definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  data SUBRC type SYSUBRC read-only .
  data MSGV1 type SYMSGV read-only .
  data MSGV2 type SYMSGV read-only .
  data MSGV3 type SYMSGV read-only .
  data MSGV4 type SYMSGV read-only .

      "! Raise exception with text
      "! @parameter iv_text | Text
      "! @parameter ix_previous | Previous exception
      "! @raising zcx_abapgit_exception | Exception
  class-methods RAISE
    importing
      !IV_TEXT type CLIKE
      !IX_PREVIOUS type ref to CX_ROOT optional
    raising
      ZCX_MQBA_EXCEPTION .
      "! Raise exception with T100 message
      "! <p>
      "! Will default to sy-msg* variables. These need to be set right before calling this method.
      "! </p>
      "! @parameter iv_msgid | Message ID
      "! @parameter iv_msgno | Message number
      "! @parameter iv_msgv1 | Message variable 1
      "! @parameter iv_msgv2 | Message variable 2
      "! @parameter iv_msgv3 | Message variable 3
      "! @parameter iv_msgv4 | Message variable 4
      "! @raising zcx_abapgit_exception | Exception
  class-methods RAISE_T100
    importing
      value(IV_MSGID) type SYMSGID default SY-MSGID
      value(IV_MSGNO) type SYMSGNO default SY-MSGNO
      value(IV_MSGV1) type SYMSGV default SY-MSGV1
      value(IV_MSGV2) type SYMSGV default SY-MSGV2
      value(IV_MSGV3) type SYMSGV default SY-MSGV3
      value(IV_MSGV4) type SYMSGV default SY-MSGV4
    raising
      ZCX_MQBA_EXCEPTION .
  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !SUBRC type SYSUBRC optional
      !MSGV1 type SYMSGV optional
      !MSGV2 type SYMSGV optional
      !MSGV3 type SYMSGV optional
      !MSGV4 type SYMSGV optional .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      gc_generic_error_msg TYPE string VALUE `An error occured (ZCX_ABAPGIT_EXCEPTION)` ##NO_TEXT.
ENDCLASS.



CLASS ZCX_MQBA_EXCEPTION IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->SUBRC = SUBRC .
me->MSGV1 = MSGV1 .
me->MSGV2 = MSGV2 .
me->MSGV3 = MSGV3 .
me->MSGV4 = MSGV4 .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  METHOD RAISE.
    DATA: lv_msgv1    TYPE symsgv,
          lv_msgv2    TYPE symsgv,
          lv_msgv3    TYPE symsgv,
          lv_msgv4    TYPE symsgv,
          ls_t100_key TYPE scx_t100key,
          lv_text     TYPE string.

    IF iv_text IS INITIAL.
      lv_text = gc_generic_error_msg.
    ELSE.
      lv_text = iv_text.
    ENDIF.

    cl_message_helper=>set_msg_vars_for_clike( lv_text ).

    ls_t100_key-msgid = sy-msgid.
    ls_t100_key-msgno = sy-msgno.
    ls_t100_key-attr1 = 'MSGV1'.
    ls_t100_key-attr2 = 'MSGV2'.
    ls_t100_key-attr3 = 'MSGV3'.
    ls_t100_key-attr4 = 'MSGV4'.
    lv_msgv1 = sy-msgv1.
    lv_msgv2 = sy-msgv2.
    lv_msgv3 = sy-msgv3.
    lv_msgv4 = sy-msgv4.

    RAISE EXCEPTION TYPE zcx_mqba_exception
      EXPORTING
        textid   = ls_t100_key
        msgv1    = lv_msgv1
        msgv2    = lv_msgv2
        msgv3    = lv_msgv3
        msgv4    = lv_msgv4
        previous = ix_previous.
  ENDMETHOD.


  METHOD raise_t100.
    DATA: ls_t100_key TYPE scx_t100key.

    ls_t100_key-msgid = iv_msgid.
    ls_t100_key-msgno = iv_msgno.
    ls_t100_key-attr1 = 'MSGV1'.
    ls_t100_key-attr2 = 'MSGV2'.
    ls_t100_key-attr3 = 'MSGV3'.
    ls_t100_key-attr4 = 'MSGV4'.

    IF iv_msgid IS INITIAL.
      CLEAR ls_t100_key.
    ENDIF.

    RAISE EXCEPTION TYPE zcx_mqba_exception
      EXPORTING
        textid = ls_t100_key
        msgv1  = iv_msgv1
        msgv2  = iv_msgv2
        msgv3  = iv_msgv3
        msgv4  = iv_msgv4.
  ENDMETHOD.
ENDCLASS.
