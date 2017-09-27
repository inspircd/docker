#!/bin/sh

########################################
###                                  ###
### DON'T EDIT THIS FILE AFTER BUILD ###
###                                  ###
###    USE ENVIRONMENT VARIABLES     ###
###              INSTEAD             ###
###                                  ###
########################################


# generateLinkBlock <NAME> <IPADDR> <PORT> <SENDPASS> <RECVPASS> <ALLOWMASK> <MORE>
generateLinkBlock() {
if [ "$6" = "" ]; then
    echo "<die reason value=\"Wrong configured link block. Please check your configs! For details see: https://github.com/inspircd/inspircd-docker#linking-servers-and-services\">"
    exit 1
fi
cat <<EOF
<link name="${1}"
      ipaddr="${2}"
      port="${3}"
      sendpass="${4}"
      recvpass="${5}"
      allowmask="${6}"
      ${7}>
EOF
}

# filterEnv SELECTOR SUFFIX
filterEnv() {
    env | grep "INSP_${1}_${2}" | sed -e 's/^[^=]*=//'
}



# Initialize settings
NAME="$(filterEnv "$1" "NAME")"
IPADDR="$(filterEnv "$1" "IPADDR")"
PORT="$(filterEnv "$1" "PORT")"
PASSWORD="$(filterEnv "$1" "PASSWORD")"
SENDPASS="$(filterEnv "$1" "SENDPASS")"
RECVPASS="$(filterEnv "$1" "RECVPASS")"
ALLOWMASK="$(filterEnv "$1" "ALLOWMASK")"
TLS_ON="$(filterEnv "$1" "TLS_ON")"
FINGERPRINT="$(filterEnv "$1" "FINGERPRINT")"
OPTIONS="$(filterEnv "$1" "OPTIONS")"
AUTOCONNECT="$(filterEnv "$1" "AUTOCONNECT")"

# Set sendpass to password if it's not further specified
if [ "$SENDPASS" = "" ] && [ "$PASSWORD" != "" ]; then
    SENDPASS="$PASSWORD"
fi

# Set recvpass to password if it's not further specified
if [ "$RECVPASS" = "" ] && [ "$PASSWORD" != "" ]; then
    RECVPASS="$PASSWORD"
fi

# Check if all needed settings are present
if [ "${SENDPASS}" != "" ] && [ "${RECVPASS}" != "" ] && [ "${NAME}" != "" ] && [ "$IPADDR" != "" ]; then
    # Enable TLS by default
    if [ "$TLS_ON" = "" ]; then
        TLS_ON="yes"
    fi

    # Set default port
    if [ "$PORT" = "" ] && [ "$TLS_ON" = "yes" ]; then
        PORT=7001
    else
        PORT=7000
    fi

    # When not specified, try to be smart and predict a allowmask
    if [ "$ALLOWMASK" = "" ]; then
        ALLOWMASK=$(ip  route show dev eth0 | grep -v default | cut -d" " -f1 | head -1)
    fi

    # Set TLS support by extending the generation config extension
    if [ "${TLS_ON}" = "yes" ]; then
        OPTIONS="$OPTIONS ssl=\"gnutls\""
    fi

    if [ "$FINGERPRINT" != "" ]; then
        FINGERPRINT=$(echo "$FINGERPRINT" | tr '[:upper:]' '[:lower:]' | sed -e 's/://g')
        OPTIONS="$OPTIONS fingerprint=\"$FINGERPRINT\""
    fi

    # generate link block
    generateLinkBlock "$NAME" "$IPADDR" "$PORT" "$SENDPASS" "$RECVPASS" "$ALLOWMASK" "$OPTIONS"

    # Add default value
    if [ "$AUTOCONNECT" = "" ]; then
        AUTOCONNECT="yes"
    fi

    # Setup <autoconnect> block to automatically connect to servers
    if [ "$AUTOCONNECT" = "yes" ]; then
        echo "<autoconnect period=\"30\" server=\"$NAME\">"
    fi
fi
