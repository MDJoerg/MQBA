*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 10.07.2018 at 17:17:34
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTC_MQBACPD.....................................*
DATA:  BEGIN OF STATUS_ZTC_MQBACPD                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTC_MQBACPD                   .
CONTROLS: TCTRL_ZTC_MQBACPD
            TYPE TABLEVIEW USING SCREEN '2001'.
*...processing: ZTC_MQBAGIBL....................................*
DATA:  BEGIN OF STATUS_ZTC_MQBAGIBL                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTC_MQBAGIBL                  .
CONTROLS: TCTRL_ZTC_MQBAGIBL
            TYPE TABLEVIEW USING SCREEN '2010'.
*...processing: ZTC_MQBAGIWL....................................*
DATA:  BEGIN OF STATUS_ZTC_MQBAGIWL                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTC_MQBAGIWL                  .
CONTROLS: TCTRL_ZTC_MQBAGIWL
            TYPE TABLEVIEW USING SCREEN '2020'.
*.........table declarations:.................................*
TABLES: *ZTC_MQBACPD                   .
TABLES: *ZTC_MQBAGIBL                  .
TABLES: *ZTC_MQBAGIWL                  .
TABLES: ZTC_MQBACPD                    .
TABLES: ZTC_MQBAGIBL                   .
TABLES: ZTC_MQBAGIWL                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
