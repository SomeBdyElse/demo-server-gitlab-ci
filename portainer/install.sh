#!/bin/bash
[ -z $DEMO_SERVER_HOSTNAME ] && echo "Need to set DEMO_SERVER_HOSTNAME in your environment" && exit 1;
[ -z $admin_auth_string ] && echo "Need to set admin_auth_string in your environment" && exit 1;

docker stack deploy portainer --compose-file docker-compose.yml