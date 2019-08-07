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

# Create config directory for testing
TESTDIR=/tmp/test-customBuild/
mkdir -p "$TESTDIR"

cp -r . "$TESTDIR"

wget -O "$TESTDIR/modules/m_timedstaticquit.cpp"  "https://raw.githubusercontent.com/inspircd/inspircd-contrib/master/3.0/m_timedstaticquit.cpp"

[ ! -e "$TESTDIR/modules/m_timedstaticquit.cpp" ] && sleep 10

docker build /tmp/test-customBuild/

# Build a second time to have a hash (everything is cached so it's no real build)
DOCKERIMAGE=$(docker build -q "$TESTDIR")

# Run container in a simple way
DOCKERCONTAINER=$(docker run -d -p "127.0.0.1:${CLIENT_PORT}:6667" -p "127.0.0.1:${TLS_CLIENT_PORT}:6697" "${DOCKERIMAGE}")

sleep 5

# Copy the custom module to the local test environemt
docker cp "${DOCKERCONTAINER}:/inspircd/modules/m_timedstaticquit.so" "$TESTDIR"

[ -s "$TESTDIR/m_timedstaticquit.so"  ] || { echo >&2 "File empty, test failed!"; exit 1; }

docker ps -f id="${DOCKERCONTAINER}"

# Clean up
docker stop "${DOCKERCONTAINER}" && docker rm "${DOCKERCONTAINER}" && docker rmi "${DOCKERIMAGE}"
