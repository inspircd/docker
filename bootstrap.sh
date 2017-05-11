#!/bin/sh

# Fail fast
set -e

# Some useful functions. See https://www.shivering-isles.com/helpful-shell-snippets-for-docker-testing-and-bootstrapping/
command_exists() { command -v "$1" >/dev/null 2>&1 || { echo >&2 "I require $1 but it's not installed.  Aborting."; exit 1; }; }
docker_installed() { command -v docker >/dev/null 2>&1 || { wget -O- http://get.docker.com | sh - ; }; command -v docker >/dev/null 2>&1 || { echo >&2 "I require docker but it's not installed and I can't install it myself.  Aborting."; exit 1; }; }

command_exists wget
docker_installed

# Workaround for CentOS and maybe more OSes where docker.service is not started automatically
# See https://github.com/Adam-/inspircd-docker/issues/35
if command -v systemctl >/dev/null 2>&1; then
    # Make sure docker unit exists
    if [ "$(systemctl cat docker | wc -l)" -ne 0 ]; then
        # Only act if the docker unit is not already active
        if ! systemctl --quiet is-active docker; then
            systemctl start docker
            systemctl enable docker
            echo "!! INFO !!                                                          !! INFO !!"
            echo "!! INFO !! We started and enabled the docker service on your system !! INFO !!"
            echo "!! INFO !!                                                          !! INFO !!"
        fi
    fi ;
fi


# Check to make sure we can talk to the docker daemon
[ -w /var/run/docker.sock ] || SUDO=sudo

# Default run parameter
RUNPARAM="-d"

# Check for available ports
if [ "$(netstat -ln | grep -c :6667)" -eq 0 ]; then
   RUNPARAM="$RUNPARAM -p 6667:6667"
else
   RUNPARAM="$RUNPARAM -p 6667"
   echo "exposing 6667 on random port. Check \'docker ps\' for details"
fi

if [ "$(netstat -ln | grep -c :6697)" -eq 0 ]; then
   RUNPARAM="$RUNPARAM -p 6697:6697"
else
   RUNPARAM="$RUNPARAM -p 6697"
   echo "exposing 6697 on random port. Check \'docker ps\' for details"
fi

# shellcheck disable=SC2086
$SUDO docker run $RUNPARAM inspircd/inspircd-docker
