#!/usr/bin/env sh

set -eux

# Start OpenDNSSEC daemon (in background), ods-enforcerd, ods-signerd
su - opendnssec -c 'ods-control start'

# Import the initial KASP
su - opendnssec -c 'ods-enforcer policy import'

# Add each zone found in the unsigned directory.
for zone in /var/opendnssec/unsigned/*
do
    [ -f "$zone" ] || break

    su - opendnssec -c "ods-enforcer zone add -z $(basename "$zone") -p lab ||
        echo $zone: Already added zone!"
done

exec "$@"
