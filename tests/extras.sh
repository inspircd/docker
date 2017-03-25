#!/bin/sh
echo "
         ######################################
         ###       Custom build test         ##
         ######################################
"


# Make sure tests fails if a commend ends without 0
set -e

# Generate some random ports for testing
CLIENT_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=10000 -v r=19999 '{printf "%i\n", f + r * $1 / 65536}')
TLS_CLIENT_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=20000 -v r=29999 '{printf "%i\n", f + r * $1 / 65536}')
SERVER_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=30000 -v r=39999 '{printf "%i\n", f + r * $1 / 65536}')
TLS_SERVER_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=40000 -v r=49999 '{printf "%i\n", f + r * $1 / 65536}')


# Make sure the ports are not already in use. In case they are rerun the script to get new ports.
[ $(netstat -an | grep LISTEN | grep :$CLIENT_PORT | wc -l) -eq 0 ] || { ./$0 && exit 0 || exit 1; }
[ $(netstat -an | grep LISTEN | grep :$TLS_CLIENT_PORT | wc -l) -eq 0 ] || { ./$0 && exit 0 || exit 1; }
[ $(netstat -an | grep LISTEN | grep :$SERVER_PORT | wc -l) -eq 0 ] || { ./$0 && exit 0 || exit 1; }
[ $(netstat -an | grep LISTEN | grep :$TLS_SERVER_PORT | wc -l) -eq 0 ] || { ./$0 && exit 0 || exit 1; }

TESTMODULE="m_svsoper"

# Create directory for testing
mkdir /tmp/test-extras/

docker build --build-arg EXTRASMODULES="$TESTMODULE" .

# Build a second time to have a hash (everything is cached so it's no real build)
DOCKERIMAGE=$(docker build -q  --build-arg EXTRASMODULES="$TESTMODULE" .)

# Run container in a simple way
DOCKERCONTAINER=$(docker run -d -p 127.0.0.1:${CLIENT_PORT}:6667 -p 127.0.0.1:${TLS_CLIENT_PORT}:6697 ${DOCKERIMAGE})

sleep 5

# Copy the custom module to the local test environemt
docker cp ${DOCKERCONTAINER}:/inspircd/modules/$TESTMODULE.so /tmp/test-extras/

[ -s "/tmp/test-extras/$TESTMODULE.so"  ] || { echo >&2 "File empty, test failed!"; exit 1; }

docker ps -f id=${DOCKERCONTAINER}

# Clean up
docker stop ${DOCKERCONTAINER} && docker rm ${DOCKERCONTAINER} && docker rmi ${DOCKERIMAGE}
