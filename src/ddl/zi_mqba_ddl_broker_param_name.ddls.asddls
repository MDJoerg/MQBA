@AbapCatalog.sqlViewName: 'ZI_MQBA_CPANB'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Broker Config ParamName from Interface - Interface view'
define view ZI_MQBA_DDL_Broker_Param_Name 
as select from ZI_MQBA_DDL_OO_Constants as NAME

{
    substring( REPLACE( Attribute, '_NAME', '' ), 9, 40) as ParameterID, 
    REPLACE(Value, '''', '' ) as ParameterName,
    
    Language, 
    Description 
}
where ABAPType  = 'ZIF_MQBA_BROKER'
  and Attribute like 'C_PARAM%NAME'
