#!/bin/sh
echo "
         ######################################
         ###       basic config test        ###
         ######################################
"


# Make sure tests fails if a command exits with non-zero
set -e

SERVERNAME="test.example.com"

# Run container in a simple way
DOCKERCONTAINER=$(docker run -d -e "INSP_SERVER_NAME=$SERVERNAME" inspircd:testing)
sleep 10

docker logs "${DOCKERCONTAINER}" 2>/dev/null | grep $SERVERNAME

# Clean up
docker stop "${DOCKERCONTAINER}" && docker rm "${DOCKERCONTAINER}"
