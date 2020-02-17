# docker-opendnssec-softhsm

This is a repository which builds a "minimalistic" (500M) OpenDNSSEC + SoftHSM instance
to sign zone files. The image will start `ods-enforcerd` and `ods-signerd` in
the background and then use `syslog` in foreground as PID 1. The image is based on [Alpine Linux].

## Supported tags

* [`latest`]

## Running OpenDNSSEC

To run an instance of the container with OpenDNSSEC and SoftHSM just start a
container with the image.

```sh
docker run --name opendnssec -d bombsimon/opendnssec-softhsm
```

Zones found in `/var/opendnssec/unsigned` on startup will be added automatically
and the zone will be named the same as the file found.

If the container was started without any zones mounted to above mentioned path
you can add them manually. For details, see the OpenDNSSEC reference. An example
with the [example.com] zone in this repository would look like this:

```sh
docker cp example.com opendnssec:/var/opendnssec/unsigned
docker exec opendnssec ods-enforcer zone add -z example.com -p lab
```

Signed zones are located in `/var/opendnssec/signed`.

## References

* [OpenDNSSEC]
* [SoftHSM]
* [OpenDNSSEC GitHub project]
* [OpenDNSSEC Wiki]
* [OpenDNSSEC Lab & Training]

## Building

The container will build four packages from source which makes the container
building a bit slow. The reason for this is to avoid deep dependencies and
support deployment on an Alpine Linux.

First of all we build `gost engine` since it's no longer bundled with SSL >=
`1.1.1` but is required for SoftHSM. We then build `ldns` from source so we can
compile it with `openssl` instead of `libressl` which the package in the apk
repository is built upon.

When we've built `ldns` we will first build `softhsm` and then `opendnssec`. To
build a new version of the container run

```sh
docker build --no-cache -t opendnssec-softhsm .
```

### Software and versions

| Software       | Version        |
| -------------- | -------------- |
| [Alpine Linux] | 3.9.4 (latest) |
| [GOST Engine]  | 1.1.0.3        |
| [LDNS]         | 1.7.1          |
| [OpenDNSSEC]   | 2.1.4          |
| [OpenSSL]      | 1.1.1b-r1      |
| [SoftHSM]      | 2.5.0          |

  [`latest`]: https://github.com/bombsimon/docker-opendnssec-softhsm/blob/master/Dockerfile
  [Alpine Linux]: https://alpinelinux.org/
  [GOST engine]: https://github.com/gost-engine/engine
  [LDNS]: https://www.nlnetlabs.nl/projects/ldns/about/
  [OpenDNSSEC GitHub project]: https://github.com/opendnssec
  [OpenDNSSEC Lab & Training]: https://github.com/opendnssec/odslab
  [OpenDNSSEC Wiki]: https://wiki.opendnssec.org/display/DOCS20
  [OpenDNSSEC]: https://www.opendnssec.org/
  [OpenSSL]: https://pkgs.alpinelinux.org/package/v3.9/main/x86/openssl-dev
  [SoftHSM]: https://www.opendnssec.org/softhsm/
  [example.com]: example.com
