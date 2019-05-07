FROM alpine:3.9 as builder

LABEL maintainer1="Adam <adam@anope.org>" \
      maintainer2="Sheogorath <sheogorath@shivering-isles.com>"

ARG VERSION=insp3
ARG CONFIGUREARGS=
#ARG EXTRASMODULES=
ARG BUILD_DEPENDENCIES=
ARG RUN_DEPENDENCIES=

# Stage 0: Build from source
COPY modules/ /src/modules/

RUN apk add --no-cache --virtual .build-utils gcc g++ make git pkgconfig perl \
       perl-net-ssleay perl-crypt-ssleay perl-lwp-protocol-https \
       perl-libwww wget gnutls-dev $BUILD_DEPENDENCIES

RUN addgroup -g 10000 -S inspircd
RUN adduser -u 10000 -h /inspircd/ -D -S -G inspircd inspircd

RUN git clone https://github.com/inspircd/inspircd.git inspircd

WORKDIR /inspircd
RUN git checkout $(git describe --abbrev=0 --tags $VERSION)

## TODO add module support here

RUN ./configure $CONFIGUREARGS --disable-interactive --uid 10000 --gid 10000
RUN make -j`getconf _NPROCESSORS_ONLN` install

## Replace vanilla config files with the ones in this repo
RUN rm -rf /inspircd/run/conf/
COPY conf/ /inspircd/run/conf/

# Stage 1: Create optimized runtime container
FROM alpine:3.9
RUN apk add --no-cache libgcc libstdc++ gnutls gnutls-utils $RUN_DEPENDENCIES && \
    addgroup -g 10000 -S inspircd && \
    adduser -u 10000 -h /inspircd/ -D -S -G inspircd inspircd

COPY --from=builder --chown=inspircd:inspircd /inspircd/run/ /inspircd/run/
WORKDIR /inspircd/run/

USER inspircd
EXPOSE 6667 6697 7000 7001
ENTRYPOINT ["./bin/inspircd", "--nofork"]