#!/bin/bash
if [ -f /home/db2inst1/sqllib/db2profile ]; then
    . /home/db2inst1/sqllib/db2profile
fi

sql="SELECT T1.APPLICATION_HANDLE, varchar(T2.APPLICATION_NAME,25) AS APPLICATION_NAME, varchar(T2.APPLICATION_ID,50) as APPLICAITON_ID, T1.UOW_ID, T1.ACTIVITY_ID, T1.ACTIVITY_STATE, varchar(T1.ACTIVITY_TYPE,15) as ACTIVITY_TYPE, T1.TOTAL_CPU_TIME, T1.ROWS_READ, T1.ROWS_RETURNED as ROWS_RETURNED FROM TABLE(MON_GET_ACTIVITY(NULL,-1)) T1 INNER JOIN TABLE(MON_GET_CONNECTION(NULL, -1)) T2 ON T1.APPLICATION_HANDLE=T2.APPLICATION_HANDLE ORDER BY T1.APPLICATION_HANDLE ASC"

if [ ! -z "$1" ]; then
    while true; do
        clear
        db2 ${qsl}
        sleep $1
    done
else
    clear
    db2 ${sql}
fi 
