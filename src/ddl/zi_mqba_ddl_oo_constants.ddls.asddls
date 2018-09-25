@AbapCatalog.sqlViewName: 'ZI_MQBA_AOCON'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Contants of ABAP OO Elements'
@VDM.viewType: #BASIC
define view ZI_MQBA_DDL_OO_Constants 
    as select from vseoattrib  
{
    //VSEOATTRIB 
    clsname         as ABAPType, 
    cmpname         as Attribute, 
    version         as Version, 
    langu           as Language, 
    descript        as Description, 
    attvalue        as Value,
    
    // additional
    length(cmpname) as AttributeLength
}
where exposure = '2'
  and attdecltyp = '2'
