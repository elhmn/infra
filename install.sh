#!/bin/bash

source $(dirname $0)/lib.sh

function update() {
	sudo apt-get update
}

function install_webhook() {
	if ! command_exist webhook; then
		echo "Installing webhook"
		sudo apt-get install webhook -y
	fi
}

# we are installing ufw if it is not present on the host
# let's note that ufw does not have an uninstall function
# because we probably don't want to remove it from the host
function install_ufw() {
	if ! command_exist ufw; then
		echo "Installing ufw"
		sudo apt-get install ufw -y
	fi
}

# Installing docker using instructions from:
# https://docs.docker.com/engine/install/ubuntu
function install_docker() {
	if ! command_exist docker; then
		echo "Installing docker"

		# install packages to allow apt to use a repository over HTTPS
		sudo apt-get install ca-certificates curl gnupg

		# Add Docker’s official GPG key
		sudo install -m 0755 -d /etc/apt/keyrings
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
		sudo chmod a+r /etc/apt/keyrings/docker.gpg

		# Set up the repository
		echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

		# Update the `apt` package index
		sudo apt-get update

		# install the latest version
		sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
	fi
}

LOGFILE=$LOGDIR/install.log
{
	# updating ubuntu version
	# ideally we would run it only once
	update 1>/dev/null

	install_ufw
	install_webhook
	install_docker
} 2>&1 | tee $LOGFILE
