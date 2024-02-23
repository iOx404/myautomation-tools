#!/usr/bin/bash

if [ "$#" -ne 1 ]
then 
	echo "Usage: $0 <filename>"
	exit 1
fi

filename=$1

echo "Searching the file name in your system please wait $filename......."

result=$(find / -type f -iname "$filename" 2>/dev/null)
# you can write in both way above or down i prefer first one 
# result=`find / -type f -iname "$filename" 2>/dev/null`

if [ -n "$result" ]
then
	echo -n "File found at :"
	echo "$result"

else
	echo "File NOt Found."
fi
