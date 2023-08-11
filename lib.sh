#!/bin/bash

#Setup logs folder
LOGDIR=$(dirname $0)/logs
if [ ! -d $LOGDIR ]; then
	mkdir -p $LOGDIR
	test -f $LOGDIR || mkdir -p $LOGDIR
fi

LOGFINAL=$LOGDIR/final
exec 4>$LOGFINAL

function command_exist() {
	command=$1
	return $(type $command &>/dev/null; echo $?)
}

# echo_final will append your text
# to a temporary file that will be displayed
# at the end of the script calling the
# `display_final` function
function echo_final() {
	echo $@ >> $LOGFINAL
}

function display_final() {
	echo ""
	cat $LOGFINAL
	rm -rf $LOGFINAL
}
