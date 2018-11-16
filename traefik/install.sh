#!/bin/bash
[ -z $DEMO_SERVER_HOSTNAME ] && echo "Need to set DEMO_SERVER_HOSTNAME in your environment" && exit 1;
[ -z $admin_auth_string ] && echo "Need to set admin_auth_string in your environment" && exit 1;
[ -z $GODADDY_API_KEY ] && echo "Need to set GODADDY_API_KEY in your environment" && exit 1;
[ -z $GODADDY_API_SECRET ] && echo "Need to set GODADDY_API_SECRET in your environment" && exit 1;

docker stack deploy traefik --compose-file docker-compose.yml
