#!/bin/sh
echo "
         ######################################
         ###       Shellcheck test           ##
         ######################################
"


# Make sure tests fails if a command exits with non-zero
set -e

# Run shellcheck for all shell scripts (including tests)
# https://github.com/koalaman/shellcheck
# shellcheck disable=SC2046
docker run --rm -v "$(pwd):/mnt" koalaman/shellcheck -x $(find ./**/*.sh)
