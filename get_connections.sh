#!/bin/bash
if [ -f /home/db2inst1/sqllib/db2profile ]; then
    . /home/db2inst1/sqllib/db2profile
fi

db2 connect to insvndb

sql="SELECT CURRENT_TIMESTAMP AS sample_time, application_handle, varchar(application_name,20) as APPLICATION_NAME, varchar(system_auth_id,15) as SYSTEM_AUTH_ID, varchar(client_hostname,20) as  CLIENT_HOSTNAME, varchar(CLIENT_WRKSTNNAME,20) as CLIENT_WRKSTNNAME, connection_start_time FROM TABLE(MON_GET_CONNECTION(NULL, -1)) ORDER BY application_handle ASC"

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
