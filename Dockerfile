FROM alpine:3.5

MAINTAINER Adam adam@anope.org
MAINTAINER Sheogorath <sheogorath@shivering-isles.com>

ARG VERSION=insp20
ARG CONFIGUREARGS=
ARG EXTRASMODULES=
ARG RUN_DEPENDENCIES=
ARG BUILD_DEPENDENCIES=

COPY modules /src/modules

RUN apk add --no-cache --virtual .build-utils gcc g++ make git pkgconfig perl \
       perl-net-ssleay perl-crypt-ssleay perl-lwp-protocol-https \
       perl-libwww wget gnutls-dev $BUILD_DEPENDENCIES && \
    # Install all permanent packages as long-therm dependencies
    apk add --no-cache --virtual .dependencies libgcc libstdc++ gnutls gnutls-utils $RUN_DEPENDENCIES && \
    # Create a user to run inspircd later
    adduser -u 10000 -h /inspircd/ -D -S inspircd && \
    mkdir -p /src /conf && \
    cd /src && \
    # Clone the requested version
    git clone https://github.com/inspircd/inspircd.git inspircd --depth 1 -b $VERSION && \
    cd /src/inspircd && \
    # Add and overwrite modules
    { [ $(ls /src/modules/ | wc -l) -gt 0 ] && cp -r /src/modules/* /src/inspircd/src/modules/ || echo "No modules overwritten/added by repository"; } && \
    # write a little script to handle empty extra modules
    echo $EXTRASMODULES | xargs --no-run-if-empty ./modulemanager install && \ 
    # Enable GNUtls with SHA256 fingerprints
    ./configure --enable-extras=m_ssl_gnutls.cpp $CONFIGUREARGS && \
    ./configure --disable-interactive --prefix=/inspircd/ --uid 10000  \
        --with-cc='c++ -DINSPIRCD_GNUTLS_ENABLE_SHA256_FINGERPRINT' && \
    # Run build multi-threaded
    make -j`getconf _NPROCESSORS_ONLN` && \
    make install && \
    # Uninstall all unnecessary tools after build process
    apk del .build-utils && \
    # Keep example configs as good reference for users
    cp -r /inspircd/conf/examples/ /conf && \
    rm -rf /src && \
    rm -rf /inspircd/conf && \
    ln -s /dev/stdout /inspircd/logs/ircd.log && \
    # Make sure the application is allowed to write to it's own direcotry for 
    # logging and generation of certificates
    chown -R inspircd /inspircd/ && \
    chown -R inspircd /conf/

# Copy the config after the build enables us to use the caching layer as base 
# instead of rebuild the whole image when you only changed a few lines in the 
# config or the entrypoing script.
COPY conf /conf
COPY entrypoint.sh /inspircd/

# Create a volume in case you want to keep your configs using docker volumes.
# Don't use this location if you want to mount a host directory.
#
# Volumes are prefilled with the same content while host directories stay empty.
# In order to minimize the delta we persist this directory in case of docker 
# volumes but use it as source to fill the empty host directory if you want to
# mount it.
#
# This helps newbies and people who want to modify the config a little bit.
VOLUME ["/conf"]

WORKDIR /inspircd/

USER inspircd

EXPOSE 6667 6697 7000 7001

# Run a really basic health check which makes sure the port is open.
HEALTHCHECK CMD  /usr/bin/nc 127.0.0.1 6667 < /dev/null || exit 1

ENTRYPOINT ["/inspircd/entrypoint.sh"]
