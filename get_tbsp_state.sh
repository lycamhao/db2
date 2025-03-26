#!/bin/bash
if [ -f /home/db2inst1/sqllib/db2profile ]; then
    . /home/db2inst1/sqllib/db2profile
fi

db2 connect to insvndb

sql="SELECT SUBSTR(TBSP_NAME,1,30) AS TBSP_NAME, SUBSTR(TBSP_STATE,1,18) AS TBSP_STATE FROM TABLE(MON_GET_TABLESPACE('',-2)) WHERE TBSP_NAME LIKE '%DATA' WITH UR "

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
