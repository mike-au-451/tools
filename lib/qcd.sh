#!/bin/bash

# shellcheck disable=SC2086
# SC2086: Double quote to prevent globbing and word splitting.

# qcd runs in a subshell.
# capture the output and execute cd in the current shell.
# allow usage like 'qq foo' with the alias
# The temp files allow running scripts in the current shell, so for example
# environment can be set.

function qcd-run {
	TF1=$(mktemp)
	TF2=$(mktemp)
	perl $HOME/bin/qcd.pl $@ > $TF1
	while read
	do
		if [[ -d "$REPLY" ]]
		then
			cd $REPLY
			break
		else
			echo $REPLY >> $TF2
		fi
	done < $TF1

	if [[ -s $TF2 ]]
	then
		source $TF2
	fi

	rm $TF1 $TF2
}

alias qq=qcd-run

