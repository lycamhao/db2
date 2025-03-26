#!/bin/bash
if [ -f /home/db2inst1/sqllib/db2profile ]; then
    . /home/db2inst1/sqllib/db2profile
fi

db2 connect to insvndb

sql="SELECT VARCHAR(TABSCHEMA,25) AS TABSCHEMA, VARCHAR(TABNAME,40) AS TABANME, T1.ROWS_READ, T1.ROWS_INSERTED, T1.ROWS_UPDATED, T1.ROWS_DELETED, T1.TABLE_SCANS, T1.TAB_TYPE, T2.TBSP_ID, VARCHAR(T2.TBSP_NAME,25) FROM TABLE(MON_GET_TABLE(NULL,NULL,-1)) T1 INNER JOIN TABLE(MON_GET_TABLESPACE(NULL,-1)) T2 ON T1.TBSP_ID = T2.TBSP_ID WHERE TAB_TYPE = 'USER_TABLE' AND TABSCHEMA NOT IN ('DB2ADMIN','DB2INST1','SYSTOOLS') AND TABNAME = '${2}' ORDER BY T1.TABLE_SCANS DESC WITH UR"

if [ ! -z "$1" ]; then
    while true; do
        clear
        db2 ${sql}
        sleep $1
    done
else
    clear
    db2 ${sql}
fi 
