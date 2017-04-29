#!/bin/sh
echo "
         ######################################
         ###       Shellcheck test           ##
         ######################################
"


# Make sure tests fails if a commend ends without 0
set -e

# Run shellcheck for all shell scripts (including tests)
# https://github.com/koalaman/shellcheck
# shellcheck disable=SC2046
docker run --rm -v "$(pwd):/mnt:z" koalaman/shellcheck -x $(find ./**/*.sh)
