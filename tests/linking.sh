#!/bin/sh
echo "
         ######################################
         ###          Linking test           ##
         ######################################
"


# Make sure tests fails if a command exits with non-zero
set -e

# shellcheck source=tests/.portconfig.sh
. "$(dirname "$0")/.portconfig.sh"

# Create a network where the containers will run on
DOCKERNETWORK=$(docker network create linkingTestNet)

# Run first instance of InspIRCd to connect to.
DOCKERCONTAINER1=$(docker run -d --name test1 --network linkingTestNet -e INSP_SERVER_NAME="test1.example.com" -e INSP_LINK1_NAME="test2.example.com" -e INSP_LINK1_PASSWORD="test" -e INSP_LINK1_IPADDR="test2" inspircd:testing --debug)

sleep 5

# Run seconds InspIRCd instance
DOCKERCONTAINER2=$(docker run -d --name test2 --network linkingTestNet -e INSP_SERVER_NAME="test2.example.com" -e INSP_LINK1_NAME="test1.example.com" -e INSP_LINK1_PASSWORD="test" -e INSP_LINK1_IPADDR="test1" inspircd:testing --debug)

sleep 10

# Check logs of the deamons
if ! docker logs "$DOCKERCONTAINER1" | grep "LINK:.*Received.*end.*of.*netburst.*from.*test2.example.com"; then
    sleep 60;
fi
docker logs "$DOCKERCONTAINER2" | grep "LINK:.*Received.*end.*of.*netburst.*from.*test1.example.com"

# Clean up
docker stop "${DOCKERCONTAINER1}" "${DOCKERCONTAINER2}" && docker rm "${DOCKERCONTAINER1}" "${DOCKERCONTAINER2}" && docker network rm "$DOCKERNETWORK"
