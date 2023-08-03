#!/bin/bash

# echo $1
# exit

case $1 in
aadd)
	# autoadd
	git status | perl -ne '/^\s+modified:\s+(.+)/ && print "$1\n"' | xargs git add
	;;
br)
	shift
	git branch "$@"
	;;
co)
	shift
	git checkout "$@"
	;;
fh)
	shift
	if [[ -z "$@" ]]
	then
		echo "ERROR: missing file(s)"
		exit 1
	fi
	git log --pretty=format:"%ai %h %s" -- $@
	;;
sls)
	shift
	git stash list
	;;
spo)
	shift
	git stash pop
	;;
spu)
	shift
	git stash push
	;;
st)
	shift
	git status "$@"
	;;
*)
	git "$@"
esac

