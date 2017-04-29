#!/bin/sh
echo "
         ######################################
         ###      Dockerfile lint test       ##
         ######################################
"


# Make sure tests fails if a command exits with non-zero
set -e

# Run linter
docker run --rm -v "$(pwd)/.dockerfilelintrc:/.dockerfilelintrc" -v "$(pwd)/Dockerfile:/Dockerfile" sheogorath/dockerfilelint /Dockerfile
