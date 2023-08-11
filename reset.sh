#!/bin/bash

source $(dirname $0)/lib.sh

function unset_swarm_manager() {
	sudo docker swarm leave --force
}

function unset_swarm_worker() {
	sudo docker swarm leave
	sudo docker network rm traefik-net
	#remove the running stacks
	sudo docker stack ls | tr -s " " "|" | tail -n +2 | cut -d "|" -f 1 | xargs sudo docker stack rm
}

LOGFILE=$LOGDIR/reset.log
{
	if [ "$1" = "manager" ]; then
		unset_swarm_manager
	else
		unset_swarm_worker
	fi
} 2>&1 | tee $LOGFILE
