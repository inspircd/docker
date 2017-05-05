#!/bin/sh
echo "
         ######################################
         ###           Release test          ##
         ######################################
"

if [ "$INSP_VERSION" = "" ]; then
    echo "\$INSP_VERSION is not set. Useless test... Exiting."
    exit 0
fi


# Check for command existence
# See: https://www.shivering-isles.com/helpful-shell-snippets-for-docker-testing-and-bootstrapping/
command_exists() { command -v "$1" >/dev/null 2>&1 || { echo >&2 "I require $1 but it's not installed.  Aborting."; exit 1; }; }

# Version comparison greater or equal
# See: https://www.shivering-isles.com/helpful-shell-snippets-for-docker-testing-and-bootstrapping/
version_ge() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1" || test "$1" = "$2"; }

# GitHub get latest release tag
# See: https://www.shivering-isles.com/helpful-shell-snippets-for-docker-testing-and-bootstrapping/
github_latest_release() { wget -qO- "https://api.github.com/repos/$1/releases/latest" | jq .tag_name | sed -e 's/"//g'; }  

command_exists wget
command_exists jq

if version_ge "$INSP_VERSION" "$(github_latest_release "inspircd/inspircd")"; then
    echo "InspIRCd version ($INSP_VERSION) is up to date! Test successful."
else
    echo >&2 "A newer base image is available! Please update. New version is $(github_latest_release "inspircd/inspircd")"
    exit 1
fi
