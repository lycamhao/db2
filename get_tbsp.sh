#!/bin/bash
if [ -f /home/db2inst1/sqllib/db2profile ]; then
    . /home/db2inst1/sqllib/db2profile
fi

db2 connect to insvndb

sql="SELECT TBSP_USED_PAGES, TBSP_FREE_PAGES, TBSP_USABLE_PAGES, TBSP_TOTAL_PAGES, TBSP_PENDING_FREE_PAGES, TBSP_PAGE_TOP, TBSP_ID, SUBSTR(TBSP_NAME,1,30) AS TBSP_NAME, TBSP_EXTENT_SIZE FROM TABLE(MON_GET_TABLESPACE('',-2)) WHERE TBSP_NAME LIKE '%DATA' ORDER BY TBSP_TOTAL_PAGES DESC WITH UR"

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
