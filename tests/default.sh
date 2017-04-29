#!/bin/sh
echo "
         ######################################
         ###          Default test           ##
         ######################################
"


# Make sure tests fails if a commend ends without 0
set -e

. $(dirname "$0")/.portconfig.sh

# Run container in a simple way
DOCKERCONTAINER=$(docker run -d -p 127.0.0.1:${CLIENT_PORT}:6667 -p 127.0.0.1:${TLS_CLIENT_PORT}:6697 inspircd:testing)
sleep 5
# Make sure TLS is working
echo quit | timeout 10 openssl s_client -ign_eof -connect localhost:${TLS_CLIENT_PORT}
# Make sure the internal healthcheck is working
sleep 28
[ $(docker ps -f id=${DOCKERCONTAINER} | grep \(healthy\) | wc -l) -eq 1 ] || exit 1

# Make sure the container is not restarting
sleep 20
docker ps -f id=${DOCKERCONTAINER}
sleep 20
docker ps -f id=${DOCKERCONTAINER}

# Clean up
docker stop ${DOCKERCONTAINER} && docker rm ${DOCKERCONTAINER}
