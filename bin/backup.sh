#!/bin/bash

# Backup files, or files in a directory, or files under a directory 
# recursively.
#
# Copies files to ROOT_BAK with a timestamp so that duplicate names dont 
# collide.
#
# Usage:
#
#     backup [--verbose] [--link] [--force] [--history] FILE...
#     backup [--verbose] [--link] DIR...
#     backup [--verbose] [--link] --recursive DIR
#
# The various forms can be used in combination.
#
# The first form backs up a list of files, the second backs up all files in a 
# list of directories, the third backs up all files and direcories recursively 
# under a single directory.
#
# Default behaviour is to backup only files which are out of date.  Use 
# --force to back up a file regarless of whether the latest version is in 
# backups.
#
# Options:
#
#     --link        create links in the original directory to the backed up 
#                   files.
#
#     --force       back up a file regardless of its current backup state.
#
#     --history		show backup history for a file
#
#     --verbose     provide extra miscellaneous information during execution.
#
# BUGS:
# 1.  Using directories is unimplemented.
# 2.  Functions should use arguments not globals.

ROOT_DIR=$PWD
ROOT_BAK=$HOME/lib/Bak
TIME_NOW=`date "+%Y%m%d_%H%M%S%N"`

DO_RECURS=
DO_FILES=
DO_DIRS=

OPT_LINK=0
OPT_FORCE=0
OPT_HISTORY=0
OPT_VERBOSE=0

function backup_files {
	for FILE in $DO_FILES
	do
		FILE=`realpath $FILE`
		DIRN=`dirname $FILE`
		BASE=`basename $FILE`

		if [ ! -d "$ROOT_BAK$DIRN" ]
		then
			[ $OPT_VERBOSE -ne 0 ] && echo "INFO: making $ROOT_BAK$DIRN"
			mkdir -p $ROOT_BAK$DIRN
		fi

		[ $OPT_VERBOSE -ne 0 ] && echo "INFO: copy $FILE"
		cp $FILE $ROOT_BAK$DIRN/${TIME_NOW}:$BASE

		[ $OPT_VERBOSE -ne 0 ] && echo "INFO: link $FILE"
		[ $OPT_LINK -ne 0 ] && ln -s $ROOT_BAK$DIRN/${TIME_NOW}:$BASE $DIRN/${TIME_NOW}:$BASE
	done
}

function history_files {
	PATTERN=
	for FILE in $DO_FILES
	do
		FILE=`realpath $FILE`
		DIRN=`dirname $FILE`
		BASE=`basename $FILE`

		PATTERN="$PATTERN|$BASE"
	done

	if [ "x$PATTERN" != "x" ]
	then
		PATTERN=${PATTERN:1}
		find $ROOT_BAK | grep -P $PATTERN | sort
	fi
}

function backup_dirs {
	for DIR in $DO_DIRS
	do
		echo "backup_dir $DIR"
	done
}

function backup_recursive {
	for DIR in $DO_RECURS
	do
		echo "backup_recurs $DIR"
	done
}

# Modify the backup list so that only files that do not match the latest 
# backed up version are backed up.
# This is the default behaviour.  Use --force to backup regardless.
function uptodate_files {
	UPDATE=
	for FILE in $DO_FILES
	do
		FILE=`realpath $FILE`
		DIRN=`dirname $FILE`
		BASE=`basename $FILE`

		LATEST=`ls -t $ROOT_BAK/$DIRN/*:$BASE 2> /dev/null | head -1`
		SUM1=`md5sum $FILE | cut -d' ' -f1`
		if [ "x$LATEST" != "x" ]
		then
			SUM2=`md5sum $LATEST | cut -d' ' -f1`
		else
			SUM2="x"
		fi
		
		if [ $SUM1 != $SUM2 ]
		then
			UPDATE="$UPDATE $FILE"
		fi
	done

	DO_FILES=$UPDATE
	backup_files
}

OPTS=`getopt -o '' --long recursive: --long verbose --long link --long force --long history -- "$@"`
if [ $? -ne 0 ]
then
	echo 'FATAL: option processing failed'
	exit 1
fi
#echo $OPTS
eval set -- "$OPTS"

RC=0
while true
do
	case $1 in
	--link)
		OPT_LINK=1
		shift
		;;
	--recursive)
		if [ ! -d $2 ]
		then
			echo "ERROR: $2 is not a directory"
			RC=1
		else
			DO_RECURS="$DO_RECURS $2"
		fi
		shift 2
		;;
	--force)
		OPT_FORCE=1
		shift
		;;
	--history)
		OPT_HISTORY=1
		shift
		;;
	--verbose)
		OPT_VERBOSE=1
		shift
		;;
	--)
		shift
		break
		;;
	*)
		echo "ERROR: unknown switch: $1"
		RC=1
		shift
		;;
	esac
done
for ARG in $@
do
	if [ -h $ARG ]
	then
		# Symlinks need to be considered:
		# Do we back up the physical file or the logical file?
		echo "ERROR: $ARG is a symlink"
		RC=1
	elif [ -d $ARG ]
	then
		DO_DIRS="$DO_DIRS $ARG"
	elif [ -f $ARG ]
	then
		DO_FILES="$DO_FILES $ARG"
	else
		echo "ERROR: $ARG must be a file or directory"
		RC=1
	fi
	shift
done
if [ $RC -ne 0 ]
then
	echo "FATAL: bad args"
	exit
fi

#echo "DO_RECURS: $DO_RECURS"
#echo "DO_FILES: $DO_FILES"
#echo "DO_DIRS: $DO_DIRS"
#echo "--link $OPT_LINK"
#echo "--force $OPT_FORCE"
#echo "--verbose $OPT_VERBOSE"
#exit

if [ "$DO_RECURS" != "" -o "$DO_DIRS" != "" ]
then
	if [ "$DO_RECURS" != "" ]
	then
		echo "ERROR: recursion is unimplemented"
	fi
	if [ "$DO_DIRS" != "" ]
	then
		echo "ERROR: directories are unimplemented"
	fi
	echo "FATAL: unimplemented function"
	exit
fi

[ $OPT_VERBOSE -ne 0 ] && echo "INFO: backup directory: $ROOT_BAK"

if [ "x$DO_FILES" != "x" ]
then
	if [ $OPT_HISTORY -ne  0 ]
	then
		history_files
	elif [ $OPT_FORCE -ne  0 ]
	then
		backup_files
	else
		uptodate_files
	fi
fi
