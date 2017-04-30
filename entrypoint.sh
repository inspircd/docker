#!/bin/sh
# shellcheck disable=SC2068

# Make sure that the volume contains a default config but don't override and existing one
if [ -d /inspircd/conf/ ]; then
    if [ ! -e /inspircd/conf/inspircd.conf ] && [ -w /inspircd/conf/ ]; then
        cp -r /conf/* /inspircd/conf/
    elif [ ! -w /inspircd/conf/ ]; then
        echo "
            ##################################
            ###                            ###
            ###   Can't write to volume!   ###
            ###    Please change owner     ###
            ###        to uid 10000        ###
            ###                            ###
            ##################################
        "
    fi
else
    ln -s /conf /inspircd/conf
fi

# Link certificates from secrets
# See https://docs.docker.com/engine/swarm/secrets/
if [ -e /run/secrets/inspircd.key ] && [ -e /run/secrets/inspircd.crt ]; then
    ln -s /run/secrets/inspircd.key /inspircd/conf/key.pem
    ln -s /run/secrets/inspircd.crt /inspircd/conf/cert.pem
fi

# Make sure there is a certificate or generate an new one
if [ ! -e /inspircd/conf/cert.pem ] && [ ! -e /inspircd/conf/key.pem ]; then
    cat > /tmp/cert.template <<EOF
cn              = "${INSP_TLS_CN:-irc.example.com}"
email           = "${INSP_TLS_MAIL:-nomail@example.com}"
unit            = "${INSP_TLS_UNIT:-Server Admins}"
organization    = "${INSP_TLS_ORG:-Example IRC Network}"
locality        = "${INSP_TLS_LOC:-Example City}"
state           = "${INSP_TLS_STATE:-Example State}"
country         = "${INSP_TLS_COUNTRY:-XZ}"
expiration_days = ${INSP_TLS_DURATION:-365}
tls_www_client
tls_www_server
signing_key
encryption_key
cert_signing_key
crl_signing_key
code_signing_key
ocsp_signing_key
time_stamping_key
EOF
    /usr/bin/certtool --generate-privkey --bits 4096 --sec-param normal --outfile /inspircd/conf/key.pem
    /usr/bin/certtool --generate-self-signed --load-privkey /inspircd/conf/key.pem --outfile /inspircd/conf/cert.pem --template /tmp/cert.template
    rm /tmp/cert.template
fi


/inspircd/bin/inspircd --nofork $@
