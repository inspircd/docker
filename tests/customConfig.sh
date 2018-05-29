#!/bin/sh
echo "
         ######################################
         ###        custom conf test         ##
         ######################################
"


# Make sure tests fails if a command exits with non-zero
set -e

# shellcheck source=tests/.portconfig.sh
. "$(dirname "$0")/.portconfig.sh"

TESTFILE="/tmp/tests-customConfig/test.conf"

mkdir -p "$(dirname $TESTFILE)"

echo "<module name=\"m_cban.so\">" >"$TESTFILE"

# Run container with configs attached
DOCKERCONTAINER=$(docker run -d -v "$TESTFILE:/inspircd/conf.d/test.conf" -p "127.0.0.1:${CLIENT_PORT}:6667" -p "127.0.0.1:${TLS_CLIENT_PORT}:6697" inspircd:testing)

# Make sure the container is not restarting
sleep 20
docker ps -f id="${DOCKERCONTAINER}"
sleep 20
docker ps -f id="${DOCKERCONTAINER}"

docker logs "$DOCKERCONTAINER" | grep "m_cban.so"

# Clean up
docker stop "${DOCKERCONTAINER}" && docker rm "${DOCKERCONTAINER}"
