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

# TODO the hash is not passed to the conf file correctly...I've tried different escapes but nothing works.
# If I hardcode the hash into the .conf file, I can do /oper defaultoper mypassword and it authenticates fine.
# I won't spend too much time trying to fix this as a production server really should have a separate (secret) oper.conf
cat <<OPER
<define name="operNick" value="${INSP_OPER_NICK:-defaultoper}">
<define name="operPasswordHash" value="${INSP_OPER_PASSWORD_HASH:-TOCFVJa2ABgfWUzFVP6ki244mn9iDMcZ7R1u2BHqc1w$7112bLuSvpFdzS+atgcx1A+hkHMo+6KlVMhekzlUbZo}">
<define name="operPasswordHashAlgorithm" value="${INSP_OPER_PASSWORD_HASH_ALGORITHM:-hmac-sha512}">
OPER