FROM alpine:3.4

MAINTAINER Adam adam@anope.org
MAINTAINER Sheogorath <sheogorath@shivering-isles.com>

RUN apk update && apk add gcc g++ make git gnutls gnutls-dev gnutls-c++ pkgconfig libssl1.0 openssl openssl-dev perl perl-net-ssleay perl-io-socket-ssl perl-libwww geoip geoip-dev pcre-dev pcre wget

COPY conf /conf

RUN adduser -u 10000 -h /inspircd/ -D -S inspircd && \
    mkdir -p /src /conf && \
    cd /src && \
#    git clone https://github.com/inspircd/inspircd.git inspircd -b master && \
    git clone https://github.com/inspircd/inspircd.git inspircd -b insp20 && \
    cd /src/inspircd && \
#    ./configure --development --disable-interactive --prefix=/inspircd/ --uid 10000 --enable-gnutls && \
    ./configure --disable-interactive --prefix=/inspircd/ --uid 10000 --enable-gnutls && \
    make && \
    make install && \
    apk del gcc g++ make git perl perl-net-ssleay perl-io-socket-ssl perl-libwww wget && \
    rm -rf /src && \
    rm -rf /inspircd/conf && ln -s /conf /inspircd/conf

VOLUME ["/inspircd/conf"]



WORKDIR /inspircd/

USER inspircd

EXPOSE 6667 6697

ENTRYPOINT ["/inspircd/bin/inspircd"]
CMD ["--nofork"]
