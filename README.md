# InspIRCd

[![Build Status](https://travis-ci.org/Adam-/inspircd-docker.svg?branch=master)](https://travis-ci.org/Adam-/inspircd-docker)

InspIRCd is a modular Internet Relay Chat (IRC) server written in C++ for Linux, BSD, Windows and Mac OS X systems which was created from scratch to be stable, modern and lightweight.

InspIRCd is one of only a few IRC servers to provide a tunable number of features through the use of an advanced but well-documented module system. By keeping core functionality to a minimum we hope to increase the stability, security, and speed of InspIRCd while also making it customizable to the needs of many different users.

# Bootstrapping

The easiest way to run this image is using our bootstrap script.

To use it run the following statement:

```console
wget -qO- https://raw.githubusercontent.com/Adam-/inspircd-docker/master/bootstrap.sh | sh
```

The bootstrap script takes care of the fact that docker is installed and runs the image.

If port `6697` or `6667` are already in use another random port is used. Otherwise, those ports are allocated by the container.

# How to use this image

First, a simple run command:

```console
$ docker run --name ircd -p 6667:6667 inspircd/inspircd-docker
```

This will start an InspIRCd instance listening on the default IRC port 6667 on the container.

To include your configuration into the container use:

```console
$ docker run --name inspircd -p 6667:6667 -v /path/to/your/config:/inspircd/conf/ inspircd/inspircd-docker
```

*Notice: In case you provide an empty directory make sure it's owned by UID 10000. Use `chown 10000 directory` to correct permissions*

Default ports of this container image:

|Port|Configuration     |
|----|------------------|
|6667|clients, plaintext|
|6697|clients, TLS      |
|7000|server, plaintext |
|7001|server, TLS       |


## Generated configuration

Instead of including your own configuration files, this container allows you to manipulate a few options of the default configuration by environment variables.

Use the following environment variables to configure your container:

|Available variables      |Default value                   |Description                                   |
|-------------------------|--------------------------------|----------------------------------------------|
|`INSP_NET_SUFFIX`        |`.example.com`                  |Suffix used behind the server name            |
|`INSP_NET_NAME`          |`Omega`                         |Name advertised as network name               |
|`INSP_SERVER_NAME`       |Container ID + `INSP_NET_SUFFIX`|Full container name. Has to be an FQDN        |
|`INSP_ADMIN_NAME`        |`Jonny English`                 |Name showed by the `/admin` command           |
|`INSP_ADMIN_NICK`        |`MI5`                           |Nick showed by the `/admin` command           |
|`INSP_ADMIN_EMAIL`       |`jonny.english@example.com`     |E-mail shown by the `/admin` command          |
|`INSP_ENABLE_DNSBL`      |`yes`                           |Set to `no` to disable DNSBLs                 |

A quick example how to use the environment variables:

```console
$ docker run --name inspircd -p 6667:6667 -e "INSP_NET_NAME=MyExampleNet" inspircd/inspircd-docker
```

## Oper

We provide two possibly ways to define a default oper for the server. 

If neither `INSP_OPER_PASSWORD_HASH`, nor `INSP_OPER_FINGERPRINT` is configured, no oper will be provided to keep your server secure.

Further details see official [`opers.conf` docs](https://github.com/inspircd/inspircd/blob/insp20/docs/conf/opers.conf.example#L77-L165).

### Password authentication

A normal password authentication uses `/oper <opername> <password>` (everything case sensitive)

To generate a password hash connect to the network and use `/mkpasswd <hash-type> <password>`.

|Available variables      |Default value                   |Description                                   |
|-------------------------|--------------------------------|----------------------------------------------|
|`INSP_OPER_NAME`         |`oper`                          |Oper name                                     |
|`INSP_OPER_PASSWORD_HASH`|no default                      |Hash value for your oper password hash        |
|`INSP_OPER_HOST`         |`*@*`                           |Hosts allowed to oper up                      |
|`INSP_OPER_HASH`         |`hmac-sha256`                   |Hashing algorithm for `INSP_OPER_PASSWORD`    |
|`INSP_OPER_SSLONLY`      |`yes`                           |Allow oper up only while using TLS            |
|`INSP_OPER_PASSWORD`     |no default                      |(deprecated) Alias `INSP_OPER_PASSWORD_HASH`  |


For example to oper up with `/oper oper s3cret` you would run the following line:

```console
$ docker run --name inspircd -p 6667:6667 -p 6697:6697 -e "INSP_OPER_PASSWORD_HASH=cNkbWRWn\$MhSTITMbrCxp0neoDqL66/MSI2C+oxIa4Ux6DXb5R4Q" inspircd/inspircd-docker
```

*Make sure you escape special chars like `$` or `&` if needed*

### Client certificate authentication

This way only works using TLS connection and uses a client certificate for authentication.

Provide the SHA256 fingerprint of the certificate as `INSP_OPER_FINGERPRINT` to configure it.

|Available variables      |Default value                   |Description                                   |
|-------------------------|--------------------------------|----------------------------------------------|
|`INSP_OPER_NAME`         |`oper`                          |Oper name for usage with `/oper`              |
|`INSP_OPER_FINGERPRINT`  |no default                      |Oper TLS fingerprint (SHA256)                 |
|`INSP_OPER_AUTOLOGIN`    |`yes`                           |Automatic login of with TLS fingerprint       |


## Linking servers and services

### Links

With this container you can link other servers. To do so you have to define a few environment variables.

Currently we allow 3 links per container. Those link variables are `INSP_LINK1_*`, `INSP_LINK2_*`, and `INSP_LINK3_*`.

We only list the possible options once, but they work for `INSP_LINK1_*`, as well as for `INSP_LINK2_*` and `INSP_LINK3_*`.

|Available variables      |Default value                   |Description                                   |
|-------------------------|--------------------------------|----------------------------------------------|
|`INSP_LINK1_NAME`        |no default                      |Name of the remote server (`INSP_SERVER_NAME`)|
|`INSP_LINK1_IPADDR`      |no default                      |IP or hostname of the remote server           |
|`INSP_LINK1_PORT`        |`7001` (TLS) or `7000`          |Port used to connect the remote server        |
|`INSP_LINK1_SENDPASS`    |no default                      |Password send by this server                  |
|`INSP_LINK1_RECVPASS`    |no default                      |Password send by remote server                |
|`INSP_LINK1_PASSWORD`    |no default                      |Alias for `sendpass` and `recvpass`           |
|`INSP_LINK1_ALLOWMASK`   |first container subnet          |CIDR of remote server's IP address            |
|`INSP_LINK1_TLS_ON`      |`yes`                           |Turn on TLS encryption for the link           |
|`INSP_LINK1_FINGERPRINT` |no default                      |TLS Fingerprint of the remote server (SHA256) |
|`INSP_LINK1_OPTIONS`     |no default                      |Allows additional to set options to `<link>`  |
|`INSP_LINK1_AUTOCONNECT` |`yes`                           |Enables `<autoconnect>` for this link         |

### Services

This image allows you to configure services link blocks by environment variables.

This way you can easily connect [Anope](https://www.anope.org/) or [Atheme](http://atheme.net/) to your InspIRCd container.

|Available variables      |Default value                   |Description                                   |
|-------------------------|--------------------------------|----------------------------------------------|
|`INSP_SERVICES_NAME`     |`services` + `INSP_NET_SUFFIX`  |Name of the services host                     |
|`INSP_SERVICES_IPADDR`   |`services`                      |IP or hostname of services                    |
|`INSP_SERVICES_ALLOWMASK`|first container subnet          |CIDR of services source IP                    |
|`INSP_SERVICES_HIDDEN`   |`no`                            |Hide services from `/MAP` and `/LINKS`        |
|`INSP_SERVICES_SENDPASS` |no default                      |Password send by this server                  |
|`INSP_SERVICES_RECVPASS` |no default                      |Password send by the services                 |
|`INSP_SERVICES_PASSWORD` |no default                      |Alias for `sendpass` and `recvpass`           |
|`INSP_SERVICES_TLS_ON`   |`no`                            |Turn on TLS encryption for the services link  |
|`INSP_SERVICES_OPTIONS`  |no default                      |Allows additional to set options to `<link>`  |

If you want to link `services.example.com` for example, you have to specify at least the `INSP_SERVICES_PASSWORD`:

```consle
$ docker run --name inspircd -p 6667:6667 -p 6697:6697 -e "INSP_SERVICES_PASSWORD=somesecretpassword" inspircd/inspircd-docker
```

*Make sure you run the services and InspIRCd container on the same docker network or specify the correct `INSP_SERVICES_ALLOWMASK`*


## TLS

### Using self-generated certificates

This container image generates a self-signed TLS certificate on start-up as long as none exists. To use this container with TLS enabled:

```console
$ docker run --name inspircd -p 6667:6667 -p 6697:6697 inspircd/inspircd-docker
```

You can customize the self-signed TLS certificate using the following environment variables:

|Available variables      |Default value                   |Description                                   |
|-------------------------|--------------------------------|----------------------------------------------|
|`INSP_TLS_CN`            |`irc.example.com`               |Common name of the certificate                |
|`INSP_TLS_MAIL`          |`nomail@example.com`            |Mail address represented in the certificate   |
|`INSP_TLS_UNIT`          |`Server Admins`                 |Unit responsible for the service              |
|`INSP_TLS_ORG`           |`Example IRC Network`           |Organisation name                             |
|`INSP_TLS_LOC`           |`Example City`                  |City name                                     |
|`INSP_TLS_STATE`         |`Example State`                 |State name                                    |
|`INSP_TLS_COUNTRY`       |`XZ`                            |Country Code by [ISO 3166-1 ](https://en.wikipedia.org/wiki/ISO_3166-1)|
|`INSP_TLS_DURATION`      |`365`                           |Duration until the certificate expires        |


This will generate a self-signed certificate for `irc.example.org` instead of `irc.example.com`:

```console
$ docker run --name inspircd -p 6667:6667 -p 6697:6697 -e "INSP_TLS_CN=irc.example.org" inspircd/inspircd-docker
```

### Using secrets

We provide the ability to use `secrets` with this image to place a certificate to your nodes.

**Docker version 1.13 is required and [secrets are only supported in swarm mode](https://docs.docker.com/engine/swarm/secrets/)**

```console
docker secret create irc.key /path/to/your/ircd.key
docker secret create inspircd.crt /path/to/your/ircd.crt

docker service create --name inspircd --secret source=irc.key,target=inspircd.key,mode=0400 --secret inspircd.crt inspircd/inspircd-docker
```

Notice the syntax `--secret source=irc.key,target=inspircd.key` allows you to name a secret in a way you like.

Currently used secrets:

* `inspircd.key`
* `inspircd.crt`

## Generic configuration includes

To extend the default configuration you can use `/inspircd/conf.d/`.

All `.conf`-files placed there, by mounting or extending the image, are automatically included.

```console
$ docker run --name inspircd -p 6667:6667 -v /path/to/your/configs:/inspircd/conf.d/ inspircd/inspircd-docker
```

*You have to take care about possible conflicts with the existing configuration. If you want a full custom configuration,
copy or mount it to `/inspircd/conf/` instead of `/inspircd/conf.d/`.*


### Using secrets

Additional to the `conf.d/` directory we offer a automated includes for all `.conf` files that are mounted as secrets.

For example to add your own oper configuration.

```console
docker secret create secret-opers /path/to/your/opers.conf

docker service create --name inspircd --secret secret-opers inspircd/inspircd-docker
```

# Build extras

To build extra modules you can use the `--build-arg` statement.

Available build arguments:

|Argument            |Description                                                              |
|--------------------|-------------------------------------------------------------------------|
|`VERSION`           |Version of InspIRCd. Uses `-b`-parameter from `git clone`                |
|`CONFIGUREARGS`     |Additional Parameters. Used to enable core extras like `m_geoip.cpp`     |
|`EXTRASMODULES`     |Additional Modules from [inspircd-extras](https://github.com/inspircd/inspircd-extras/tree/master/2.0) repository like `m_geoipban`|
|`BUILD_DEPENDENCIES`|Additional packages which are only needed during compilation             |
|`RUN_DEPENDENCIES`  |Additional packages which are needed to run InspIRCd                     |

```console
docker build --build-arg "BUILD_DEPENDENCIES=geoip-dev pcre-dev" --build-arg "RUN_DEPENDENCIES=geoip pcre" --build-arg "CONFIGUREARGS=--enable-extras=m_geoip.cpp --enable-extras=m_regex_pcre.cpp"  --build-arg "EXTRASMODULES=m_geoipban" inspircd-docker
```

## Building additional modules

In case you want to develop InspIRCd modules, it is useful to run InspIRCd with modules which neither exist in core modules nor in extras.

You can put the sources these modules in the modules directory of this repository. They are automatically copied to the modules directory of InspIRCd.

It also allows you to overwrite modules.

Make sure you install all needed dependencies using `ADDPACKAGES`.


# Updates and updating

To update your setup simply pull the newest image version from docker hub and run it.

```console
docker pull inspircd/inspircd-docker
```

We automatically build our images weekly to include the current state of modern libraries.

Considering to update your docker setup regularly.

## Deprecated features

We provide information about features we remove in future.

* `INSP_OPER_PASSWORD` - was replaced by `INSP_OPER_PASSWORD_HASH` as more descriptive name

## Breaking changes

We document changes that possibly broken your setup and are no longer supported. Hopefully, we can provide useful information for debugging.

* [`cdba94f`](https://github.com/Adam-/inspircd-docker/commit/cdba94f6ae0c71ad37b3a88114a14ecb0c5177c1) `ADDPACKAGES` and `DELPACKAGES` are replaced by `BUILD_DEPENDENCIES` and `RUN_DEPENDENCIES`

# Additional information

By default this image ships DNSBL settings for [DroneBL](http://dronebl.org) and [EFnet RBL](http://efnetrbl.org/).

This should provide a basic protection for your server, but also causes problems if you want to use [Tor](https://www.torproject.org/) or open proxies.

Set `INSP_ENABLE_DNSBL` to `no` to disable them.

# License

View [license information](https://github.com/inspircd/inspircd) for the software contained in this image.

# Supported Docker versions

This image is officially supported on Docker version 17.03.1-CE.

Support for older versions (down to 1.12) is provided on a best-effort basis.

Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker daemon.

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/Adam-/inspircd-docker/issues).

You can also reach many of the project maintainers via the `#inspircd` IRC channel on [Chatspike](https://chatspike.net).

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests and do our best to process them as fast as we can.
