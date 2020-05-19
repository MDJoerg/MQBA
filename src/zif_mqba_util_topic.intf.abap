interface ZIF_MQBA_UTIL_TOPIC
  public .


  methods SET_TOPIC_MASK
    importing
      !IV_MASK type DATA
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods GET_TOPIC_MASK
    returning
      value(RV_MASK) type STRING .
  methods GET_MASK_PARTS
    returning
      value(RT_PARTS) type ZMQBA_UTL_T_TOPIC_PARTS .
  methods GET_PARAMETERS
    returning
      value(RT_PARAMS) type ZMQBA_T_STRING .
  methods SET_TOPIC
    importing
      !IV_TOPIC type STRING
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods GET_PARAMETER_VALUES
    returning
      value(RT_PARAM_VALUES) type ZMQBA_T_PARAM_VALUE .
  methods SET_PARAMETER_VALUES
    importing
      value(IT_PARAM_VALUES) type ZMQBA_T_PARAM_VALUE .
  methods GET_PARAMETER
    importing
      !IV_PARAM type STRING
    returning
      value(RV_VALUE) type STRING .
  methods SET_PARAMETER
    importing
      !IV_PARAM type STRING
      !IV_VALUE type STRING .
  methods RESET_PARAMETER .
  methods RESET .
  methods BUILD_TOPIC
    importing
      !IT_PARAM type ZMQBA_T_PARAM_VALUE optional
    returning
      value(RV_TOPIC) type STRING .
endinterface.
