*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 06.11.2018 at 23:24:28
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTC_MQBABRK.....................................*
DATA:  BEGIN OF STATUS_ZTC_MQBABRK                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTC_MQBABRK                   .
CONTROLS: TCTRL_ZTC_MQBABRK
            TYPE TABLEVIEW USING SCREEN '2060'.
*...processing: ZTC_MQBACMP.....................................*
DATA:  BEGIN OF STATUS_ZTC_MQBACMP                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTC_MQBACMP                   .
CONTROLS: TCTRL_ZTC_MQBACMP
            TYPE TABLEVIEW USING SCREEN '2030'.
*...processing: ZTC_MQBACPD.....................................*
DATA:  BEGIN OF STATUS_ZTC_MQBACPD                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTC_MQBACPD                   .
CONTROLS: TCTRL_ZTC_MQBACPD
            TYPE TABLEVIEW USING SCREEN '2001'.
*...processing: ZTC_MQBACSA.....................................*
DATA:  BEGIN OF STATUS_ZTC_MQBACSA                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTC_MQBACSA                   .
CONTROLS: TCTRL_ZTC_MQBACSA
            TYPE TABLEVIEW USING SCREEN '2040'.
*...processing: ZTC_MQBACSM.....................................*
DATA:  BEGIN OF STATUS_ZTC_MQBACSM                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTC_MQBACSM                   .
CONTROLS: TCTRL_ZTC_MQBACSM
            TYPE TABLEVIEW USING SCREEN '2050'.
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
TABLES: *ZTC_MQBABRK                   .
TABLES: *ZTC_MQBACMP                   .
TABLES: *ZTC_MQBACPD                   .
TABLES: *ZTC_MQBACSA                   .
TABLES: *ZTC_MQBACSM                   .
TABLES: *ZTC_MQBAGIBL                  .
TABLES: *ZTC_MQBAGIWL                  .
TABLES: ZTC_MQBABRK                    .
TABLES: ZTC_MQBACMP                    .
TABLES: ZTC_MQBACPD                    .
TABLES: ZTC_MQBACSA                    .
TABLES: ZTC_MQBACSM                    .
TABLES: ZTC_MQBAGIBL                   .
TABLES: ZTC_MQBAGIWL                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
