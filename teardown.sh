#!/bin/bash

source $(dirname $0)/lib.sh

function uninstall_webhook() {
	if command_exist webhook; then
		echo "Installing webhook"
		sudo apt-get purge --auto-remove webhook -y
	fi
}

function uninstall_docker() {
	if command_exist docker; then
		sudo apt-get purge --auto-remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras -y

		#cleanup all possible docker install
		commands="docker.io docker-doc docker-compose podman-docker containerd runc"
		for cmd in $commands; do
			sudo apt-get purge --auto-remove $cmd -y
		done
	fi
}

LOGDIR=$(dirname $0)/logs/teardown.log
{
	uninstall_webhook
	uninstall_docker
} 2>&1 | tee $LOGFILE
