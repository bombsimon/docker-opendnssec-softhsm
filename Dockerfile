FROM alpine:latest

ARG GOST_ENGINE_VERSION=1.1.0.3
ARG OPENDNSSEC_VERSION=2.1.4
ARG SOFTHSM_VERSION=2.5.0
ARG LDNS_VERSION=1.7.0
ARG USER=opendnssec

WORKDIR /opendnssec

RUN apk add --update \
    cmake \
    g++ \
    gcc \
    git \
    libxml2-dev \
    openssl-dev \
    make \
    perl \
    sqlite-dev \
    tar \
    wget


RUN mkdir -p /opendnssec/build

# Build GOST engine which is required for SOFTHSM. This is no longer bundled in
# openssl >= 1.1.1
RUN cd /opendnssec/build && \
    git clone https://github.com/gost-engine/engine.git && \
    mkdir -p engine/build && cd engine/build && \
    git checkout v${GOST_ENGINE_VERSION} && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . --config Release && \
    mkdir -p /usr/lib/engines-1.1/ && \
    cp ../bin/gost.so /usr/lib/engines-1.1/

# Install LDNS from source. We don't want to install this from the apk mirror
# since that package is built upon (and thus dependent) on libressl. We want to
# use alpine > 3.6 and openssl-dev for opendnssec instead.
RUN cd /opendnssec/build && \
    wget https://www.nlnetlabs.nl/downloads/ldns/ldns-${LDNS_VERSION}.tar.gz && \
    tar zxf ldns-${LDNS_VERSION}.tar.gz && \
    cd ldns-${LDNS_VERSION} && \
    ./configure --disable-dane-ta-usage && \
    make && make install

# Install SoftHSM from source.
RUN cd /opendnssec/build && \
    wget https://dist.opendnssec.org/source/softhsm-${SOFTHSM_VERSION}.tar.gz && \
    tar zxf softhsm-${SOFTHSM_VERSION}.tar.gz && \
    cd softhsm-${SOFTHSM_VERSION} && \
    ./configure && \
    make && make install

# Install OpenDNSSEC from source.
RUN cd /opendnssec/build && \
    wget https://dist.opendnssec.org/source/opendnssec-${OPENDNSSEC_VERSION}.tar.gz && \
    tar zxf opendnssec-${OPENDNSSEC_VERSION}.tar.gz && \
    cd opendnssec-${OPENDNSSEC_VERSION} && \
    ./configure && \
    make && make install

# Remove build artifacts
RUN rm -fr /opendnssec/build

# Remove packages and build files we no longer need.
RUN apk del \
    cmake \
    g++ \
    git \
    make \
    perl \
    tar \
    wget

# Add user to not run as root
RUN adduser -D -u 1000 ${USER}

# Change permissions on files and folders which should be owned by the
# opendnssec user.
RUN chown -R ${USER}:${USER} \
    /etc/opendnssec \
    /var/lib/softhsm \
    /var/log \
    /var/opendnssec \
    /var/run/opendnssec \
    /opendnssec

# Initialize and reassign SoftHSM token slot
RUN su - ${USER} -c \
    'softhsm2-util --init-token --slot 0 --label OpenDNSSEC --pin 1234 --so-pin 1234'

# Erase and setup KASP as opendnssec user on build.
RUN su - ${USER} -c \
    'yes | ods-enforcer-db-setup'

COPY ./docker-entrypoint.sh /opendnssec/

ENTRYPOINT [ "/opendnssec/docker-entrypoint.sh", "syslogd", "-n", "-O", "-" ]
