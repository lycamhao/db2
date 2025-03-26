#!/bin/bash
if [ -f /home/db2inst1/sqllib/db2profile ]; then
    . /home/db2inst1/sqllib/db2profile
fi

while true; do
    clear
    db2pd -db insvndb -logs | awk 'NR<=25'
    echo -e "\n"
    echo "---------Begin Archive Log---------"
    echo -e "\nArchive log path: /db2arclog/db2inst1/INSVNDB/NODE0000/LOGSTREAM0000/C0000000"
    echo -e "\n"
    ls -lrt /db2arclog/db2inst1/INSVNDB/NODE0000/LOGSTREAM0000/C0000000 | tail -n 1 
    echo "---------End Archive Log Section--------"
    sleep $1
done
