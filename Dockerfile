FROM alpine:latest

ARG OPENDNSSEC_VERSION=2.1.3
ARG SOFTHSM_VERSION=2.5.0
ARG LDNS_VERSION=1.7.0
ARG USER=opendnssec

WORKDIR /opendnssec

RUN apk add --update \
	g++ \
	gcc \
	libxml2-dev \
	openssl-dev \
	make \
	perl \
	sqlite-dev \
	tar \
    wget


RUN mkdir -p /opendnssec/build

# Install LDNS from source. We don't want to install this from the apk mirror #
# since that package is built upon (and thus dependent) on libressl. We want to
#use alpine > 3.6 and openssl-dev for opendnssec instead.
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

# Add user to not run as root
RUN adduser -D -u 1000 ${USER}

# Change permissions on files and folders which should be owned by the
# opendnssec user.
RUN chown -R ${USER}:${USER} \
    /opendnssec \
	/var/lib/softhsm \
	/var/opendnssec \
	/etc/opendnssec \
	/var/run/opendnssec

# Initialize and reassign SoftHSM token slot
RUN su - opendnssec -c \
	'softhsm2-util --init-token --slot 0 --label OpenDNSSEC --pin 1234 --so-pin 1234'

# Remove packages and build files we no longer need.
RUN apk del \
	g++ \
	make \
	perl \
	tar \
	wget

RUN rm -fr /opendnssec/build

USER opendnssec

# Erease and setup database
RUN yes | ods-enforcer-db-setup

# TODO
# Start the OpenDNSSEC signer engine and enforcer + import policies.
# CMD [ "ods-control, "start" ]
# CMD [ "ods-enforcer", "policy", "import" ]
