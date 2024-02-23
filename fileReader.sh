# Author b0tx404
# similar to cat command in linux

#!/usr/bin/bash
if [ "$#" -ne 1 ]
then
	echo "Usage $0 <fileName>"
	exit 1
fi

while read line
do
	echo "$line"

done <$1