# docker-opendnssec-softhsm

This is a repository which builds a minimalistic OpenDNSSEC + SoftHSM instance
to sign zone files.

## Building

The container will build three packages from source which makes the container
building a bit slow. The reason for this is to avoid deep dependencies and
support deployment on an Alpine instance.

First we need to build `ldns` from source so we can compile it with `openssl`
instead of `libressl` which the package in the apk repository is built upon.

When we've built `ldns` we will first build `softhsm` and then `opendnssec`.

## References

* [OpenDNSSEC](https://www.opendnssec.org/)
* [SoftHSM](https://www.opendnssec.org/softhsm/)
* [OpenDNSSEC GitHub project](https://github.com/opendnssec)
* [OpenDNSSEC Wiki](https://wiki.opendnssec.org/display/DOCS20)
* [OpenDNSSEC Lab & Trainging](https://github.com/opendnssec/odslab)

## Notes

This image does not yet have a valid entrypoint or entrypoint script. To be
able to run this container you could run it interactive after building it.

```sh
docker build -t opendnssec-softhsm .
docker run -it opendnssec-softhsm /bin/sh
```

And then manually start the daemons in the container.

```sh
ods-control start
ods-enforcer policy import
```

If you want to test signing an example zone, use the [example.com](example.com)
example zone and place it in `/var/opendnssec/unsigned`. The signed zone will
be located in `/var/opendnssec/signed/example.com`.

```sh
cp example.com /var/opendnssec/unsigned
ods-enforcer zone add -z example.com -p lab
ods-signer sign example.com
cp /var/opendnssec/signed/example.com example.com.signed
```
