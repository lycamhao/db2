#!/bin/sh
INFILE=SQL-stmt-1.sql
demo=""
while read -r LINE
do
	trimmed_string=$(echo "$LINE" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/[:blank:]*$//')
	demo+=" $trimmed_string"
done < "$INFILE"

echo "$demo" > SQL-stmt-1-converted.sql

