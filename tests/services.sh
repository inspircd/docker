#!/bin/sh
echo "
         ######################################
         ###          Services test          ##
         ######################################
"


# Make sure tests fails if a command exits with non-zero
set -e

# shellcheck source=tests/.portconfig.sh
. "$(dirname "$0")/.portconfig.sh"

DOCKERNETWORK="$(docker network create services)"

# Run container in a simple way
DOCKERCONTAINER_IRCD="$(docker run --network services --network-alias inspircd -e "INSP_SERVICES_PASSWORD=password" -d inspircd:testing)"

sleep 10

DOCKERCONTAINER_SERVICES="$(docker run --network services -e "ANOPE_UPLINK_IP=inspircd" -e "ANOPE_UPLINK_PASSWORD=password" -e "ANOPE_SERVICES_NAME=services.example.com" -d anope/anope:latest)"

sleep 10

docker logs "$DOCKERCONTAINER_SERVICES"
docker logs "$DOCKERCONTAINER_SERVICES" | grep "done syncing"

# Clean up
docker stop "${DOCKERCONTAINER_IRCD}" "${DOCKERCONTAINER_SERVICES}" && docker rm "${DOCKERCONTAINER_IRCD}" "${DOCKERCONTAINER_SERVICES}" && docker network rm "${DOCKERNETWORK}"
