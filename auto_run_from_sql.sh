#!/bin/bash
if [ -f /home/db2inst1/sqllib/db2profile ]; then
    . /home/db2inst1/sqllib/db2profile
fi
folder=$1
# cd ${folder}
# pwd
# rm -rf *_with_commit.sql
countLineOfFile() {
    if [ ! -z $1 ];then
        wc -l $1
    fi
}

if [ -z $1 ];then
    echo "Please input folder location"
else
    while true;do
        files=$(find $1 -name "*.sql")
        if [ -z "${files}" ];then
            echo "No sql file in here, waiting for file"
            sleep 2
        else
            # countLineOfFile $files
            echo $files
            break
        fi
    done
fi


# for file in ${files};do
#     awk 'NR%1000==0{print "COMMIT;"}1' ${file} > ${file}_with_commit.sql
#     db2 connect to insvndb
#     db2batch -d insvndb -v on -f ./${file}_with_commit.sql -z ${file}_result.log,${file}_summary.log -c off
#     db2 connect reset
# done
# cd ~