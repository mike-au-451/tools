#!/bin/bash

# Snapshot a file, or list of files, or directory recursively.
# 
# Usage:
# 
#   snap foo
#   snap foo bar*
# 	snap dir
# 
# Bugs:
#
# 1.  Most functionality is unimplemented.
# 2.  No unsnap yet.

ERR=0
for ARG in "$@"
do
	if [[ ! -f "$ARG" ]]
	then
		echo "ERROR: missing $ARG"
		ERR=1
	fi
done
if [[ $ERR != "0" ]]
then
	echo "FATAL: bad args"
	exit
fi

SNAP=$HOME/Snapshots
[[ -d $SNAP ]] || mkdir $SNAP

YYYY=$(date +'%Y')
MOTH=$(date +'%m')
MDAY=$(date +'%d')
TIMS=$(date +'%H%M%S')

[[ -d "$SNAP/$YYYY/$MOTH" ]] || mkdir -p "$SNAP/$YYYY/$MOTH"

ROOT="$SNAP/$YYYY/$MOTH/$YYYY$MOTH${MDAY}_$TIMS"
if [[ -d "$ROOT" ]] 
then
	echo "BUG: would duplicate $ROOT"
	exit
fi
mkdir $ROOT

for ARG in "$@"
do
	if [[ ! -f "$ARG" ]]
	then
		echo "ERROR: not a file: $ARG"
		continue
	fi
	FDIR=$(dirname $(readlink -f $ARG))
	mkdir -p "$ROOT$FDIR"
	cp "$ARG" "$ROOT$FDIR"
done
