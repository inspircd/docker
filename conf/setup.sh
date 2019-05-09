#!/bin/sh

cat <<SERVER
<define name="serverFQDN" value="${INSP_SERVER_NAME:-irc}${INSP_NET_SUFFIX:-.example.com}">
<define name="networkName" value="${INSP_NETWORK_NAME:-examplenet}">
SERVER

cat <<ADMIN
<define name="adminName" value="${INSP_ADMIN_NAME:-Admins Realname}">
<define name="adminNick" value="${INSP_ADMIN_NICK:-defaultadmin}">
<define name="adminEmail" value="${INSP_ADMIN_EMAIL:-admin@irc.example.com}">
ADMIN

