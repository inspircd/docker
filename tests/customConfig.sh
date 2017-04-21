#!/bin/sh
echo "
         ######################################
         ###        custom conf test         ##
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

TESTFILE="/tmp/tests-customConfig/test.conf"

mkdir -p $(dirname $TESTFILE)

echo "<module name=\"m_cban.so\">" >"$TESTFILE"

# Run container in a simple way
DOCKERCONTAINER=$(docker run -d -v "$TESTFILE:/inspircd/conf.d/test.conf" -p 127.0.0.1:${CLIENT_PORT}:6667 -p 127.0.0.1:${TLS_CLIENT_PORT}:6697 inspircd:testing)

# Make sure the container is not restarting
sleep 20
docker ps -f id=${DOCKERCONTAINER}
sleep 20
docker ps -f id=${DOCKERCONTAINER}

docker logs $DOCKERCONTAINER | grep "m_cban.so"

# Clean up
docker stop ${DOCKERCONTAINER} && docker rm ${DOCKERCONTAINER}
