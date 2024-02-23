#!/usr/bin/bash

if [ "$#" -ne 1 ]
then 
	echo "Usage: $0 <your's Ip>"
	exit 1

fi

response=$(curl http://ip-api.com/json/$1 -s)
status=`echo $response | jq '.status' -r`

if [ $status == "success" ]
then
	country=`echo $response | jq '.country' -r`
	echo "COUNTRY:$country"

	region=`echo $response | jq '.regionName' -r`
	echo "REGION:$region"

	city=`echo $response | jq '.city' -r`
	echo "CITY:$city"

	district=`echo $response | jq '.district' -r`
	echo "DISTRICT:$district"
	
fi
