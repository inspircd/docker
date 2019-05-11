#!/bin/sh

########################################
###                                  ###
### DON'T EDIT THIS FILE AFTER BUILD ###
###                                  ###
###    USE ENVIRONMENT VARIABLES     ###
###              INSTEAD             ###
###                                  ###
########################################


# When not specified, try to be smart and predict a allowmask
if [ "$INSP_SERVICES_ALLOWMASK" = "" ]; then
    INSP_SERVICES_ALLOWMASK=$(ip  route show dev eth0 | grep -v default | cut -d" " -f1 | head -1)
fi

# Set sendpass to password if it's not further specified
if [ "$INSP_SERVICES_SENDPASS" = "" ] && [ "$INSP_SERVICES_PASSWORD" != "" ]; then
    INSP_SERVICES_SENDPASS="$INSP_SERVICES_PASSWORD"
fi

# Set recvpass to password if it's not further specified
if [ "$INSP_SERVICES_RECVPASS" = "" ] && [ "$INSP_SERVICES_PASSWORD" != "" ]; then
    INSP_SERVICES_RECVPASS="$INSP_SERVICES_PASSWORD"
fi

# Set TLS support by extending the generation config extension
if [ "${INSP_SERVICES_TLS_ON}" = "yes" ]; then
    INSP_SERVICES_OPTIONS="$INSP_SERVICES_OPTIONS ssl=\"gnutls\""
fi

# Set default services name
INSP_SERVICES_NAME="${INSP_SERVICES_NAME:-services&netsuffix;}"

if [ "${INSP_SERVICES_SENDPASS}" != "" ] && [ "${INSP_SERVICES_RECVPASS}" != "" ]; then
cat <<EOF
<link name="${INSP_SERVICES_NAME}"
      ipaddr="${INSP_SERVICES_IPADDR:-services}"
      port="7000"
      allowmask="${INSP_SERVICES_ALLOWMASK}"
      hidden="${INSP_SERVICES_HIDDEN:-no}"
      sendpass="${INSP_SERVICES_SENDPASS}"
      recvpass="${INSP_SERVICES_RECVPASS}"
      ${INSP_SERVICES_OPTIONS}>

<uline server="$INSP_SERVICES_NAME" silent="yes">

<module name="m_sasl.so">
<sasl target="$INSP_SERVICES_NAME">
EOF
fi
