#!/bin/sh
echo "
         ######################################
         ###      Dockerfile lint test       ##
         ######################################
"


# Make sure tests fails if a commend ends without 0
set -e

# Run linter
docker run --rm -v "$(pwd)/.dockerfilelintrc:/.dockerfilelintrc" -v "$(pwd)/Dockerfile:/Dockerfile" sheogorath/dockerfilelint /Dockerfile
