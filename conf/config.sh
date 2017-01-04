#!/bin/sh

# Generate some default config values
echo '<define name="hostname" value="'`hostname`'">'
echo '<define name="netsuffix" value="'${INSP_NET_SUFFIX:-.example.com}'">'
echo '<define name="netname" value="'${INSP_NET_NAME:-Omega}'">'
echo '<define name="servername" value="'${INSP_SERVER_NAME:-&hostname;&netsuffix;}'">'

# Generate generic config values based on environment variables
env | grep INSPG_ | sed -e "s/\([A-Z_]*\)=/\L\1=/g" -e "s/_\([a-zA-Z]\)/\u\1/g" -e 's/\=/" value="/' -e 's/^/\<define name="/' -e 's/$/\"\>/'

# Load config templates
/conf/templatemanager.sh ${INSP_ENABLE_TEMPLATES}
