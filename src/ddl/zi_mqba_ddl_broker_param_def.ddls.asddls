@AbapCatalog.sqlViewName: 'ZI_MQBA_CPADB'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Broker Config ParamDef from Interface - Interface view'
@VDM.viewType: #BASIC
define view ZI_MQBA_DDL_Broker_Param_Def 
as select from ZI_MQBA_DDL_OO_Constants 
{
    substring( REPLACE( Attribute, '_DEF', '' ), 9, 40) as ParameterID, 
    REPLACE(Value, '''', '' ) as DefaultValue,
    Description as DefaultDescription,     
    Language 
}
where ABAPType  = 'ZIF_MQBA_BROKER'
  and Attribute like 'C_PARAM%DEF'