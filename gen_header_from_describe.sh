#!/bin/bash
if [ -d "${HOME}/sqllib/db2profile" ]; then
    . "${HOME}/sqllib/db2profile"
fi
echo "Gen SQL from describe"
read -p "What table that you want to describe: " table
db2 connect to insvndb > /dev/null
db2 describe table "$table" > /tmp/$table.txt
a=$(wc -l < /tmp/$table.txt)
tmp=$((a - 3))
b=$(cat /tmp/$table.txt | awk 'NR >= 5 && NR <= $tmp {print $1}')
#echo "$b"
res=""
for line in $b;do
	res+="$line,"
done
res=${res%,}
host=$(hostname)
echo "$res" > ./"${table}_${host}".csv
db2 export to ./"${table}_tmp".csv of del "select * from ${table}"
cat ./"${table}_tmp".csv >> "${table}_${host}".csv
rm -rf ./"${table}_tmp".csv
#db2 connect reset > /dev/null
