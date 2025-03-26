#!/bin/ksh

if [ -f ${HOME}/sqllib/db2profile ]; then
. ${HOME}/sqllib/db2profile
fi

db2 connect to INSVNDB > /dev/null

SCHEMAS=`db2 -x "select rtrim(tabschema) from syscat.tables where rtrim(tabschema) like 'DB__' group by tabschema order by tabschema with ur"`

for SCHEMA in ${SCHEMAS}
do

  TABLES=`db2 -x "select rtrim(tabname) from syscat.tables where rtrim(tabschema)='${SCHEMA}' and type='T' and tabname not like 'ADVISE%' and tabname not like 'EXPLAIN%' order by tabname with ur"`

  for TABLE in ${TABLES}
  do

    db2 -v "export to /dbawork/dbexport_ixf/${SCHEMA}.${TABLE}.ixf of ixf modified by codepage=1208 select * from ${SCHEMA}.${TABLE} with ur"

  done

  touch /dbawork/dbexport_ixf/${SCHEMA}.OK

#ftp -n << EOF
#open 10.165.50.1
#user db2inst1 cxivnxas01
#lcd /dbawork/staging
#cd /dbawork/staging
#prom
#binary
#mput ${SCHEMA}.*.ixf
#put ${SCHEMA}.OK
#bye
#EOF

done

db2 terminate > /dev/null

