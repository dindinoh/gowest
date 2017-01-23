#!/bin/bash

source ~/.vasttrafik.key
#tput civis

function finish() {
    tput cvvis
}

DATE=$(date +%Y-%m-%d)
HOUR=$(date +%H)
MINUTE=$(date +%M)
BRR="9021014001049000"
SLT="9021014009620000"

TOKEN=$(curl -s -k \
	     -d "grant_type=client_credentials" \
	     -H "Authorization: Basic $KEY" \
	     -H "Content-Type: application/x-www-form-urlencoded" \
	     "https://api.vasttrafik.se/token" |\
               tr ',' '\n' | grep token | awk -F":" '{ print $2 }' | tail -n1 | sed -e 's/\"//g' -e 's/}//g')

NEXT=$(curl -s -k \
	    -H "Content-Type: application/x-www-form-urlencoded" \
	    -H "Authorization: Bearer $TOKEN" \
	    "https://api.vasttrafik.se/bin/rest.exe/v2/departureBoard?id=$BRR&date=$DATE&time=$HOUR%3A$MINUTE&direction=$SLT&format=json" |\
	      grep -m1 \"time\" | awk -F":" '{ print $2":"$3 }' | sed -e 's/\"//g' -e 's/,//g')

NOW=$(date +%H:%M)
IFS=: read -r old_hour old_min <<< "$NOW"
IFS=: read -r hour min <<< "$NEXT"
if [ "$hour" -eq "00" ]
then
    hour=24
fi
total_old_minutes=$((10#$old_hour*60 + 10#$old_min))
total_minutes=$((10#$hour*60 + 10#$min))
IN="$((total_minutes - total_old_minutes))"
if [ "$IN" -eq "0" ]
then
    IN="NOW"
fi
echo -e "$IN"

