#!/bin/sh

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
EOF

# Space for further configs
