#!/bin/bash
if [ -f /home/db2inst1/sqllib/db2profile ]; then
    . /home/db2inst1/sqllib/db2profile
fi
LOG="imported.log"
folder=$1
cd ${folder}
pwd
files=$(find $1 -name "*.sql")
rm -rf *_with_commit.sql
for file in ${files};do
    awk 'NR%1000==0{print "COMMIT;"}1' ${file} > ${file}_with_commit.sql
    db2 connect to insvndb
    db2batch -d insvndb -v on -f ./${file}_with_commit.sql -z ${file}_result.log,${file}_summary.log -c off
    db2 "SELECT VARCHAR(TABSCHEMA,25) AS TABSCHEMA, VARCHAR(TABNAME,40) AS TABANME, T1.ROWS_READ, T1.ROWS_INSERTED, T1.ROWS_UPDATED, T1.ROWS_DELETED, T1.TABLE_SCANS, T1.TAB_TYPE, T2.TBSP_ID, VARCHAR(T2.TBSP_NAME,25) FROM TABLE(MON_GET_TABLE(NULL,NULL,-1)) T1 INNER JOIN TABLE(MON_GET_TABLESPACE(NULL,-1)) T2 ON T1.TBSP_ID = T2.TBSP_ID WHERE TAB_TYPE = 'USER_TABLE' AND TABSCHEMA NOT IN ('DB2ADMIN','DB2INST1','SYSTOOLS') AND TABNAME = 'DTAEK200_LOG' ORDER BY T1.TABLE_SCANS DESC WITH UR" > ${LOG}
    db2 connect reset
    mail -s "DTAEK200_LOG imported info !!" sugiahoabinh2010@gmail.com < ${LOG}
done
cd ~