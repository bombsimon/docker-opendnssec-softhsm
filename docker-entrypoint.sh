#!/usr/bin/env sh

set -eux

# Erase and setup KASP as opendnssec user
su - opendnssec -c 'yes | ods-enforcer-db-setup'

# Start OpenDNSSEC daemon (in background), ods-enforcerd, ods-signerd
su - opendnssec -c 'ods-control start'

# Import the initial KASP
su - opendnssec -c 'ods-enforcer policy import'

exec "$@"
