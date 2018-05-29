#!/bin/sh
echo "
         ######################################
         ###        Oper config test         ##
         ###          (Fingerprint)          ##
         ######################################
"


# Make sure tests fails if a command exits with non-zero
set -e

# shellcheck source=tests/.portconfig.sh
. "$(dirname "$0")/.portconfig.sh"

TESTFILE="$(mktemp /tmp/operConfigFingerprint.XXXXXX)"

OPERNAME=Alice
OPERFINGERPRINT=bob
OPERAUTOLOGIN=no

mkdir -p "$(dirname "$TESTFILE")"

# Run container in a simple way
DOCKERCONTAINER=$(docker run -d -p "127.0.0.1:${CLIENT_PORT}:6667" -p "127.0.0.1:${TLS_CLIENT_PORT}:6697" -e "INSP_OPER_NAME=$OPERNAME" -e "INSP_OPER_FINGERPRINT=$OPERFINGERPRINT" -e "INSP_OPER_AUTOLOGIN=$OPERAUTOLOGIN" inspircd:testing)

sleep 10

docker exec "${DOCKERCONTAINER}" /inspircd/conf/opers.sh >"$TESTFILE"

grep "name=\"operName\" value=\"$OPERNAME\"" "$TESTFILE"
grep "name=\"operFingerprint\" value=\"$OPERFINGERPRINT\"" "$TESTFILE"
grep "fingerprint=\"&operFingerprint;\"" "$TESTFILE"

# Clean up
rm "$TESTFILE"
docker stop "${DOCKERCONTAINER}" && docker rm "${DOCKERCONTAINER}"
