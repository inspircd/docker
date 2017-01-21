#!/bin/sh

echo "
         ######################################
         ###      Mounting config test       ##
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


# Create config directory for testing
mkdir /tmp/test-mountConfig/ && sudo chown 10000 /tmp/test-mountConfig/

# Create docker container with our test parameters
DOCKERCONTAINER=$(docker run -d -v /tmp/test-mountConfig/:/inspircd/conf -p 127.0.0.1:${CLIENT_PORT}:6667 -p 127.0.0.1:${TLS_CLIENT_PORT}:6697 inspircd:testing)
sleep 5

# Check if config was created successfully
diff conf/inspircd.conf /tmp/test-mountConfig/inspircd.conf
echo quit | timeout 10 openssl s_client -ign_eof -connect localhost:${TLS_CLIENT_PORT}

# Make sure the internal healthcheck is working
sleep 28
[ $(docker ps -f id=${DOCKERCONTAINER} | grep \(healthy\) | wc -l) -eq 1 ] || exit 1

# Clean up
docker stop ${DOCKERCONTAINER} && docker rm ${DOCKERCONTAINER}

