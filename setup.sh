#!/bin/bash

source $(dirname $0)/lib.sh

function open_ports() {
	#Open swarm ports
	sudo ufw allow 2377/tcp
	sudo ufw allow 7946/tcp
	sudo ufw allow 7946/udp

	# Opening port 4789 for trusted_ips
	# and hoping that to be good enough
	# for security
	TRUSTED_IPS_FILE=$(dirname $0)/trusted_ips
	if [ ! -f $TRUSTED_IPS_FILE ]; then
		echo "$TRUSTED_IPS_FILE does not exist, please create that file using the trusted_ips.example as a template"
		return -1
	fi

	for trusted_ip in $(cat $TRUSTED_IPS_FILE); do
		sudo ufw allow from $trusted_ip to any port 4789 proto udp
	done
}

function setup_swarm_manager() {
	open_ports

	#Check that a node is a manager
	#This will setup the repo
	sudo docker node ls &>/dev/null
	if [ $? -ne 0 ]; then
		sudo docker swarm init
		sudo docker network create -d overlay traefik-net
	fi
}

function setup_swarm_worker() {
	open_ports

	echo_final "You need to manually join a swarm leader, please run"
	echo_final "\"sudo docker swarm join-token worker\" on your leaders host"
	echo_final "then, copy and paste the command \"sudo docker swarm join --token <token> host_ip:port\" from the output"
}

function setup_deployments() {
	echo "Setting up your applications"

	echo "Please provide a link to the deployment repository template"
	url=$DEPLOYMENTS_FILE
	while [ -z $url ]; do
		read -p 'Deployment url: ' url
	done

	# Clone your deploy repository
	# the repository will be stored at the root of your working directory
	deploy_file=deployments
	(
		cd $HOME
		git clone $url $deploy_file
		cd $deploy_file
	)

	# Clone sammi, that has the script to perform the deploys
	# Run the sammi deploy script
	sami_file=sami
	(
		cd $HOME
		git clone git@github.com:osscameroon/sami.git $sami_file
		cd $sami_file/scripts
		./deploy.sh $HOME/$deploy_file
	)

}

LOGFILE=$LOGDIR/setup.log
{
	source $(dirname $0)/lib.sh

	if [ "$1" = "manager" ]; then
		setup_swarm_manager
	else
		setup_swarm_worker
	fi

	setup_deployments
	display_final
} 2>&1 | tee $LOGFILE
