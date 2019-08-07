#!/bin/sh
echo "
         ######################################
         ###       Custom build test         ##
         ######################################
"


# Make sure tests fails if a command exits with non-zero
set -e

# shellcheck source=tests/.portconfig.sh
. "$(dirname "$0")/.portconfig.sh"

TESTMODULE="m_svsoper"

# Create directory for testing
mkdir -p /tmp/test-extras/

docker build --build-arg EXTRASMODULES="$TESTMODULE" .

# Build a second time to have a hash (everything is cached so it's no real build)
DOCKERIMAGE=$(docker build -q  --build-arg EXTRASMODULES="$TESTMODULE" .)

# Run container in a simple way
DOCKERCONTAINER=$(docker run -d -p "127.0.0.1:${CLIENT_PORT}:6667" -p "127.0.0.1:${TLS_CLIENT_PORT}:6697" "${DOCKERIMAGE}")

sleep 5

# Copy the custom module to the local test environemt
docker cp "${DOCKERCONTAINER}:/inspircd/modules/$TESTMODULE.so" "/tmp/test-extras/"

[ -s "/tmp/test-extras/$TESTMODULE.so"  ] || { echo >&2 "File empty, test failed!"; exit 1; }

docker ps -f id="${DOCKERCONTAINER}"

# Clean up
docker stop "${DOCKERCONTAINER}" && docker rm "${DOCKERCONTAINER}" && docker rmi "${DOCKERIMAGE}"
