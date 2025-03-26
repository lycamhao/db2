#!/bin/bash
if [ -f /home/db2inst1/sqllib/db2profile ]; then
    . /home/db2inst1/sqllib/db2profile
fi
LOG="imported.log"
folder=$1
cd ${folder}
pwd
files=$(find $1 -name "*.sql")
for file in ${files};do
    wc -l ${file}
done
cd ~