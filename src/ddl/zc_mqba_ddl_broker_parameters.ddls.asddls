@AbapCatalog.sqlViewName: 'ZC_MQBA_CPARB'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Broker Config Parameters from Interface - Consumption view'
@VDM.viewType: #CONSUMPTION
define view ZC_MQBA_DDL_Broker_Parameters 
as select from ZI_MQBA_DDL_Broker_Param_Name as NAME
association [0..1] to ZI_MQBA_DDL_Broker_Param_Def as DEF
    on NAME.ParameterID = DEF.ParameterID
{
//NAME 
cast ( ParameterID as ZMQBA_PARAM_NAME )  as ParameterID, 
cast ( ParameterName as ZMQBA_PARAM_NAME )  as ParameterName, 
Language, 
Description,

cast ( DEF.DefaultValue as ZMQBA_PARAM_VALUE_DEF )  as DefaultValue,
DEF.DefaultDescription
}
