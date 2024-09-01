FROM mcr.microsoft.com/dotnet/runtime:8.0.8-alpine3.20

RUN set -x \
    && apk add --no-cache \
        bash \
        wget \
        gcc \
        tar \
        alpine-sdk \
        perl \
        linux-headers \
        autoconf \
        automake \
        git \
        libtool \
    && rm -rf /var/cache/apk/*

ENV OPENSSL_VERSION="1.1.1w"

RUN set -x \
 ### BUILD OpenSSL
 && wget --no-check-certificate -O /tmp/openssl-${OPENSSL_VERSION}.tar.gz "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" \
 && tar -xvf /tmp/openssl-${OPENSSL_VERSION}.tar.gz -C /tmp/ \
 && rm -rf /tmp/openssl-${OPENSSL_VERSION}.tar.gz \
 && cd /tmp/openssl-${OPENSSL_VERSION} \
 && ./Configure linux-x86_64 shared\
 && make \
 && make test \
 && make install \
 && cd .. \
 && rm -rf openssl-${OPENSSL_VERSION}

ENV PATH=/usr/local/ssl/bin:$PATH

ARG SOFTHSM2_VERSION=2.6.1

ENV SOFTHSM2_VERSION=${SOFTHSM2_VERSION} \
    SOFTHSM2_SOURCES=/tmp/softhsm2

RUN git clone https://github.com/opendnssec/SoftHSMv2.git ${SOFTHSM2_SOURCES}
WORKDIR ${SOFTHSM2_SOURCES}

RUN git checkout ${SOFTHSM2_VERSION} -b ${SOFTHSM2_VERSION} \
    && sh autogen.sh \
    && ./configure \
        # --enable-gost \
        --with-crypto-backend=openssl \ 
        --with-openssl=/usr/local/ssl/bin \
        # --enable-ecc \
        # --enable-eddsa \
        --disable-non-paged-memory \
        --prefix=/usr/local \
    && make \
    && make install

WORKDIR /root
RUN rm -fr ${SOFTHSM2_SOURCES}

# install pkcs11-tool
RUN apk --update add opensc