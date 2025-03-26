#!/bin/bash
if [ -f ${HOME}/sqllib/db2profile ]; then
    . ${HOME}/sqllib/db2profile
fi
db2 connect to insvndb
db2 -tvf ~/RUN-SQL/ReservedDetailData5.sql > ~/RUN-SQL/ReservedDetailData5.log 2>&1