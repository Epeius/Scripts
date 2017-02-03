#!/bin/bash

LOOPFILE=$1 # where the loops
OUTDIR=$2 # where the s2e's output is
ALLCOUNT=0
while IFS= read -r loopaddr
do
    echo "$loopaddr"
    for process in $( seq 0 20 ) 
    do
	echo "Searching in dir-$process for $loopaddr "
        count=$(cat ${PWD}/${OUTDIR}/${process}/info.txt | grep "$loopaddr" | wc -l)
        echo $count
        ALLCOUNT=$(($ALLCOUNT + $count))
    done
done < "$LOOPFILE"

echo "ALLCOUNT is $ALLCOUNT"
