#!/bin/bash

function command_exist() {
	command=$1
	return $(type $command &>/dev/null; echo $?)
}

# Install the webhook binary
if ! command_exist webhook; then
	echo "Installing webhook"
	sudo apt-get install webhook
fi
