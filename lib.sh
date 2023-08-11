#!/bin/bash

#Setup logs folder
LOGDIR=$(dirname $0)/logs
if [ ! -d $LOGDIR ]; then
	mkdir -p $LOGDIR
	test -f $LOGDIR || mkdir -p $LOGDIR
fi

function command_exist() {
	command=$1
	return $(type $command &>/dev/null; echo $?)
}
