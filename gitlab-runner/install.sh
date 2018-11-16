#!/bin/bash
[ -z $REGISTRATION_TOKEN ] && echo "Need to set REGISTRATION_TOKEN in your environment" && exit 1;
[ -z $CI_SERVER_URL ] && echo "Need to set CI_SERVER_URL in your environment" && exit 1;

docker stack deploy gitlab-runner --compose-file docker-compose.yml