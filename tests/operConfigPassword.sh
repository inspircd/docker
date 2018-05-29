#!/bin/sh
echo "
         ######################################
         ###        Oper config test         ##
         ###           (Password)            ##
         ######################################
"


# Make sure tests fails if a command exits with non-zero
set -e

# shellcheck source=tests/.portconfig.sh
. "$(dirname "$0")/.portconfig.sh"

TESTFILE="$(mktemp /tmp/operConfigPassword.XXXXX)"

OPERNAME=Alice
OPERPASSWORD=bob
OPERHASH=sha256
OPERSSLONLY=no

mkdir -p "$(dirname "$TESTFILE")"

# Run container in a simple way
DOCKERCONTAINER=$(docker run -d -p "127.0.0.1:${CLIENT_PORT}:6667" -p "127.0.0.1:${TLS_CLIENT_PORT}:6697" -e "INSP_OPER_NAME=$OPERNAME" -e "INSP_OPER_PASSWORD_HASH=$OPERPASSWORD" -e "INSP_OPER_HASH=$OPERHASH" -e "INSP_OPER_SSLONLY=$OPERSSLONLY" inspircd:testing)

sleep 10

docker exec "${DOCKERCONTAINER}" /inspircd/conf/opers.sh >"$TESTFILE"

grep "name=\"operName\" value=\"$OPERNAME\"" "$TESTFILE"
grep "name=\"operPassword\" value=\"$OPERPASSWORD\"" "$TESTFILE"
grep "name=\"operHash\" value=\"$OPERHASH\"" "$TESTFILE"
grep "name=\"operSSLOnly\" value=\"$OPERSSLONLY\"" "$TESTFILE"
grep "password=\"&operPassword;\"" "$TESTFILE"

# Clean up
rm "$TESTFILE"
docker stop "${DOCKERCONTAINER}" && docker rm "${DOCKERCONTAINER}"
