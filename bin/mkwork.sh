#!/bin/bash

# Make dated subdirectories under /home/mike/Play 
# 
# TODO:
# 1.  Use cut-d_-f2 to determine a proper sequence number.
# 
# 
# 
# 


WORK=$HOME/Work
YEAR=$(date +%Y)
MOTH=$(date +%m)
TDAY=$(date +%Y%m%d)

[ -d "$WORK/$YEAR/$MOTH" ] || mkdir -p "$WORK/$YEAR/$MOTH"

cd "$WORK/$YEAR/$MOTH"

seq 1 5 | while read
do
	DIRN=$(printf "%s_%02d" $TDAY $REPLY)
	if [ ! -d $DIRN ]
	then
		mkdir $DIRN
		echo "$WORK/$YEAR/$MOTH/$DIRN"
		break
	fi
done



