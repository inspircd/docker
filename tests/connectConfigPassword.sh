#!/bin/sh
echo "
         ######################################
         ###       Connect config test       ##
         ###           (Password)            ##
         ######################################
"


# Make sure tests fails if a command exits with non-zero
set -e

# shellcheck source=tests/.portconfig.sh
. "$(dirname "$0")/.portconfig.sh"

TESTFILE=$(mktemp /tmp/connectConfigPassword.XXXXX)

CONNECTPASSWORD=bob
CONNECTHASH=sha256

mkdir -p "$(dirname "$TESTFILE")"

# Run container in a simple way
DOCKERCONTAINER=$(docker run -d -p "127.0.0.1:${CLIENT_PORT}:6667" -p "127.0.0.1:${TLS_CLIENT_PORT}:6697" -e "INSP_CONNECT_PASSWORD=$CONNECTPASSWORD" -e "INSP_CONNECT_HASH=$CONNECTHASH" inspircd:testing)

sleep 10

docker exec "${DOCKERCONTAINER}" /inspircd/conf/config.sh >"$TESTFILE"

grep "name=\"connectpassword\" value=\"$CONNECTPASSWORD\"" "$TESTFILE"
grep "name=\"connecthash\" value=\"$CONNECTHASH\"" "$TESTFILE"

# Clean up
rm "$TESTFILE"
docker stop "${DOCKERCONTAINER}" && docker rm "${DOCKERCONTAINER}"
