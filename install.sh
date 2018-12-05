#!/bin/bash

# SSH Connection to Swarm manager
[ -z $SWARM_MANAGER_SSH_USER ] && echo "Need to set SWARM_MANAGER_SSH_USER in your environment" && exit 1;
[ -z $SWARM_MANAGER_SSH_HOST ] && echo "Need to set SWARM_MANAGER_SSH_HOST in your environment" && exit 1;
[ -z $SWARM_MANAGER_SSH_PORT ] && export SWARM_MANAGER_SSH_PORT=22;

# Access to traefik, portainer, etc.
[ -z $DEMO_SERVER_HOSTNAME ] && echo "Need to set DEMO_SERVER_HOSTNAME in your environment" && exit 1;
[ -z $ADMIN_AUTH_USERNAME ] && echo "Need to set ADMIN_AUTH_USERNAME in your environment" && exit 1;
[ -z $ADMIN_AUTH_PASSWORD ] && echo "Need to set ADMIN_AUTH_PASSWORD in your environment" && exit 1;

# Godaddy connection for traefik SSL
[ -z $GODADDY_API_KEY ] && echo "Need to set GODADDY_API_KEY in your environment" && exit 1;
[ -z $GODADDY_API_SECRET ] && echo "Need to set GODADDY_API_SECRET in your environment" && exit 1;

# GitLab connection for gitlab runners
[ -z $CI_SERVER_URL ] && echo "Need to set CI_SERVER_URL in your environment" && exit 1;
[ -z $REGISTRATION_TOKEN ] && echo "Need to set REGISTRATION_TOKEN in your environment" && exit 1;


# Check SSH connection
echo "Check SSH connection"
status=$(ssh -o BatchMode=yes -o ConnectTimeout=5 ${SWARM_MANAGER_SSH_USER}@${SWARM_MANAGER_SSH_HOST} -p ${SWARM_MANAGER_SSH_PORT} echo ssh_ok)
if [[ $status == ssh_ok ]] ; then
  echo "SSH connection is ok"
elif [[ $status == "Permission denied"* ]] ; then
  echo "SSH Authentication error"
else
  echo "SSH connection error"
fi


# Connect to remote docker host
export DOCKER_HOST=ssh://${SWARM_MANAGER_SSH_USER}@${SWARM_MANAGER_SSH_HOST}:${SWARM_MANAGER_SSH_PORT}

# Get BasicAuth string to setup portainer and traefik access control
export admin_auth_string=$(docker run --rm --entrypoint htpasswd registry:2 -Bbn "$ADMIN_AUTH_USERNAME" "$ADMIN_AUTH_PASSWORD")

# Deploy load balancer
cd traefik
./install.sh
cd ..

echo "Wait 20secs for traefik_public network to appear"
sleep 20

# Install a docker registry
cd registry
./install.sh
cd ..

# Install portainer
cd portainer
./install.sh
cd ..

# Install a gitlab-runner
cd gitlab-runner
./install.sh
cd ..
