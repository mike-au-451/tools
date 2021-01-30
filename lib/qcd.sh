#!/bin/bash

# qcd runs in a subshell.
# capture the output and execute cd in the current shell.
# allow usage like 'qq foo' with the alias
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

	source $TF2
	rm $TF1 $TF2
}

alias qq=qcd-run

