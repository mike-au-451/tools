#!/bin/bash

# Make dated subdirectories under /home/mike/Play 
# 
# TODO:
# 1.  Use cut-d_-f2 to determine a proper sequence number.
# 
# 
# 
# 

PLAY=$HOME/Play
YEAR=$(TZ=Australia/Brisbane date +%Y)
MOTH=$(TZ=Australia/Brisbane date +%m)
TDAY=$(TZ=Australia/Brisbane date +%Y%m%d)

[ -d "$PLAY/$YEAR/$MOTH" ] || mkdir -p "$PLAY/$YEAR/$MOTH"

cd "$PLAY/$YEAR/$MOTH"

seq 1 5 | while read
do
	DIRN=$(printf "%s_%02d" $TDAY $REPLY)
	if [ ! -d $DIRN ]
	then
		mkdir $DIRN
		echo "$PLAY/$YEAR/$MOTH/$DIRN"
		break
	fi
done



