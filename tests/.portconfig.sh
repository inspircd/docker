#!/bin/sh
# shellcheck disable=SC2002,SC2046,SC2086

# Generate some random ports for testing
CLIENT_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=10000 -v r=19999 '{printf "%i\n", f + r * $1 / 65536}')
TLS_CLIENT_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=20000 -v r=29999 '{printf "%i\n", f + r * $1 / 65536}')
SERVER_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=30000 -v r=39999 '{printf "%i\n", f + r * $1 / 65536}')
TLS_SERVER_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=40000 -v r=49999 '{printf "%i\n", f + r * $1 / 65536}')


# Make sure the ports are not already in use. In case they are rerun the script to get new ports.
[ $(netstat -ln | grep -c :$CLIENT_PORT) -eq 0 ] || { ./$0 && exit 0 || exit 1; }
[ $(netstat -ln | grep -c :$TLS_CLIENT_PORT) -eq 0 ] || { ./$0 && exit 0 || exit 1; }
[ $(netstat -ln | grep -c :$SERVER_PORT) -eq 0 ] || { ./$0 && exit 0 || exit 1; }
[ $(netstat -ln | grep -c :$TLS_SERVER_PORT) -eq 0 ] || { ./$0 && exit 0 || exit 1; }

