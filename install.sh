#!/bin/bash
[ -z $DEMO_SERVER_HOSTNAME ] && echo "Need to set DEMO_SERVER_HOSTNAME in your environment" && exit 1;
[ -z $ADMIN_AUTH_USERNAME ] && echo "Need to set ADMIN_AUTH_USERNAME in your environment" && exit 1;
[ -z $ADMIN_AUTH_PASSWORD ] && echo "Need to set ADMIN_AUTH_PASSWORD in your environment" && exit 1;

# Godaddy connection for traefik SSL
[ -z $GODADDY_API_KEY ] && echo "Need to set GODADDY_API_KEY in your environment" && exit 1;
[ -z $GODADDY_API_SECRET ] && echo "Need to set GODADDY_API_SECRET in your environment" && exit 1;

# GitLab connection for gitlab runners
[ -z $CI_SERVER_URL ] && echo "Need to set CI_SERVER_URL in your environment" && exit 1;
[ -z $REGISTRATION_TOKEN ] && echo "Need to set REGISTRATION_TOKEN in your environment" && exit 1;



# ! Deploy swarm master
export SWARM_MASTER_IP=`dig +short $DEMO_SERVER_HOSTNAME |tail -n 1`

docker-machine create \
	--driver generic \
	--generic-ip-address=$SWARM_MASTER_IP \
	--generic-ssh-key ~/.ssh/id_rsa \
	--engine-storage-driver overlay \
	$DEMO_SERVER_HOSTNAME

eval $(docker-machine env $DEMO_SERVER_HOSTNAME)

echo "The master node was restarted which probably broke all overlay networks. Please restart all worker nodes in your docker swarm. Press key when done."
read

export admin_auth_string=$(docker run --rm --entrypoint htpasswd registry:2 -Bbn "$ADMIN_AUTH_USERNAME" "$ADMIN_AUTH_PASSWORD")

# Deploy load balancer
cd traefik
./install.sh
cd ..

echo "Wait for traefik_public network to appear"
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

echo "DEMO_SERVER_CACERT"
cat $DOCKER_CERT_PATH/ca.pem
echo ""

echo "DEMO_SERVER_CERT"
cat $DOCKER_CERT_PATH/cert.pem
echo ""

echo "DEMO_SERVER_KEY"
cat $DOCKER_CERT_PATH/key.pem
echo ""
