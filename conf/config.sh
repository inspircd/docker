#!/bin/sh
# shellcheck disable=SC2039

# Default variables
cat <<EOF
# Network section
<define name="hostname" value="${HOSTNAME:-irc}">
<define name="netsuffix" value="${INSP_NET_SUFFIX:-.example.com}">
<define name="netname" value="${INSP_NET_NAME:-Omega}">
<define name="servername" value="${INSP_SERVER_NAME:-&hostname;&netsuffix;}">

# Admin section
<define name="adminname" value="${INSP_ADMIN_NAME:-Jonny English}">
<define name="adminnick" value="${INSP_ADMIN_NICK:-MI5}">
<define name="adminemail" value="${INSP_ADMIN_EMAIL:-jonny.english@example.com}">

# Connect block section
<define name="usednsbl" value="${INSP_ENABLE_DNSBL:-yes}">
EOF

# Include custom configurations if conf.d exists
if [ -d conf.d ]; then
    find conf.d/*.conf | while read -r file; do echo "<include file=\"$file\">"; done
fi

# Include custom configurations from docker secrets. (For example for further oper configs)
if [ -d /run/secrets ]; then
    find /run/secrets/*.conf | while read -r file; do echo "<include file=\"$file\">"; done
fi

# Space for further configs
