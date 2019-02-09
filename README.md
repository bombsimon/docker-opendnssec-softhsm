# docker-opendnssec-softhsm

This is a repository which builds a minimalistic OpenDNSSEC + SoftHSM instance
to sign zone files.

## Versions

* Alpine Linux - `latest (3.9)`
* GOST Engine - `master (1.1.0.3)`
* LDNS - `1.7.0`
* OpenDNSSEC - `2.1.3`
* OpenSSL - `1.1.1`
* SoftHSM - `2.5.0`

## References

* [OpenDNSSEC](https://www.opendnssec.org/)
* [SoftHSM](https://www.opendnssec.org/softhsm/)
* [OpenDNSSEC GitHub project](https://github.com/opendnssec)
* [OpenDNSSEC Wiki](https://wiki.opendnssec.org/display/DOCS20)
* [OpenDNSSEC Lab & Trainging](https://github.com/opendnssec/odslab)

## Running OpenDNSSEC

To run an instance of the container with OpenDNSSEC and SoftHSM just start a
container with the image.

```sh
docker run --name opendnssec -d bombsimon/opendnssec-softhsm
```

Zones found in `/var/opendnssec/unsigned` on startup will be added automatically
and the zone will be named the same as the file found.

If the container was started without any zones mounted to above mentioned path
you can add them manually. For details, see the OpenDNSSEC reference linked
above. An example with the [example.com](example.com) zone in this repository
would look like this:

```sh
docker cp example.com opendnssec:/var/opendnssec/unsigned
docker exec opendnssec ods-enforcer zone add -z example.com -p lab
```

Signed zones are located in `/var/opendnssec/signed`.

## Building

The container will build four packages from source which makes the container
building a bit slow. The reason for this is to avoid deep dependencies and
support deployment on an Alpine Linux.

First of all we build [`gost engine`](https://github.com/gost-engine/engine)
since it's no longer bundled with SSL >= `1.1.1` but is required for SoftHSM. We
then build `ldns` from source so we can compile it with `openssl` instead of
`libressl` which the package in the apk repository is built upon.

When we've built `ldns` we will first build `softhsm` and then `opendnssec`. To
build a new version of the container run `docker build -t opendnssec-softhsm .`
