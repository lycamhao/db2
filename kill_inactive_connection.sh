#!/bin/bash
if [ -f /home/db2inst1/sqllib/db2profile ]; then
    . /home/db2inst1/sqllib/db2profile
fi

db2 connect to insvndb

db2 -x "SELECT C.APPLICATION_HANDLE FROM TABLE(MON_GET_CONNECTION(NULL, -2)) C LEFT JOIN TABLE(MON_GET_ACTIVITY(NULL, -2)) A ON C.APPLICATION_HANDLE = A.APPLICATION_HANDLE WHERE A.ACTIVITY_TYPE is NULL" > /tmp/application_handle.txt

application_handles=$(cat /tmp/application_handle.txt)
for application_handle in ${application_handles}; do
    echo "Killing ${application_handle}"
    db2 "force application (${application_handle})"
done
rm -rf /tmp/application_handle.txt
echo "Done"