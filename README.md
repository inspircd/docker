# InspIRCd

[![Build Status](https://travis-ci.org/Adam-/inspircd-docker.svg?branch=master)](https://travis-ci.org/Adam-/inspircd-docker)

InspIRCd is a modular Internet Relay Chat (IRC) server written in C++ for Linux, BSD, Windows and Mac OS X systems which was created from scratch to be stable, modern and lightweight.

InspIRCd is one of only a few IRC servers to provide a tunable number of features through the use of an advanced but well documented module system. By keeping core functionality to a minimum we hope to increase the stability, security and speed of InspIRCd while also making it customisable to the needs of many different users.

# Bootstrapping

The easiest way to run this image is using our bootstrap script.

To use it run the following statement:

```console
wget -qO- https://raw.githubusercontent.com/Adam-/inspircd-docker/master/bootstrap.sh | sh
```

The bootstrap script takes care about the fact that docker is installed and runs the image.

If port `6697` or `6667` are already in use another random port is used. Otherwise those ports are allocated by the container.

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

Instead of including of your own configuration files, this container allows you to manipulate a few options of the default configuration by environment variables.

Use the following environment variables to configure your container:

|Available variables    |Default value                   |Description                               |
|-----------------------|--------------------------------|------------------------------------------|
|`INSP_NET_SUFFIX`      |`.example.com`                  |Suffix used behind the server name        |
|`INSP_NET_NAME`        |`Omega`                         |Name advertised as network name           |
|`INSP_SERVER_NAME`     |Container ID + `INSP_NET_SUFFIX`|Full container name. Has to be a FQDN     |
|`INSP_ADMIN_NAME`      |`Jonny English`                 |Name shown by the `/admin` command        |
|`INSP_ADMIN_NICK`      |`MI5`                           |Nick shown by the `/admin` command        |
|`INSP_ADMIN_EMAIL`     |`jonny.english@example.com`     |E-mail shown by the `/admin` command      |
|`INSP_ENABLE_DNSBL`    |`yes`                           |Set to `no` to disable DNSBLs             |

A quick example how to use the environment variables:

```console
$ docker run --name inspircd -p 6667:6667 -e "INSP_NET_NAME=MyExampleNet" inspircd/inspircd-docker
```

## Oper

We provide two possibly ways to define a default oper for the server. 

If neither `INSP_OPER_PASSWORD`, nor `INSP_OPER_FINGERPRINT` is configured, no oper will provided to keep your server secure.

Further details see official [`opers.conf` docs](https://github.com/inspircd/inspircd/blob/insp20/docs/conf/opers.conf.example#L77-L165).

### Password authentication

A normal password authentication uses `/oper <opername> <password>` (everything case sensitive)


|Available variables    |Default value                   |Description                               |
|-----------------------|--------------------------------|------------------------------------------|
|`INSP_OPER_NAME`       |`oper`                          |Oper name for usage with `/oper`          |
|`INSP_OPER_PASSWORD`   |no default                      |Oper password for usage with `/oper`      |
|`INSP_OPER_HOST`       |`*@*`                           |Hosts allowed to oper up                  |
|`INSP_OPER_HASH`       |`hmac-sha256`                   |Hashing algorithm for `INSP_OPER_PASSWORD`|
|`INSP_OPER_SSLONLY`    |`yes`                           |Allow oper up only while using TLS        |


### Client certificate authentication

This way only works using TLS connection and uses a client certificate for authentication.

Provide the SHA256 fingerprint of the certificate as `INSP_OPER_FINGERPRINT` to configure it.

|Available variables    |Default value                   |Description                               |
|-----------------------|--------------------------------|------------------------------------------|
|`INSP_OPER_NAME`       |`oper`                          |Oper name for usage with `/oper`          |
|`INSP_OPER_FINGERPRINT`|no default                      |Oper TLS fingerprint (SHA256)             |
|`INSP_OPER_AUTOLOGIN`  |`yes`                           |Automatic login of with TLS fingerprint   |


## TLS

### Using self-generated certificates

This container image generates a self-signed TLS certificate on start-up as long as none exists. To use this container with TLS enabled:

```console
$ docker run --name inspircd -p 6667:6667 -p 6697:6697 inspircd/inspircd-docker
```

You can customize the self-signed TLS certificate using the following environment variables:

* `INSP_TLS_CN`
* `INSP_TLS_MAIL`
* `INSP_TLS_UNIT`
* `INSP_TLS_ORG`
* `INSP_TLS_LOC`
* `INSP_TLS_STATE`
* `INSP_TLS_COUNTRY`
* `INSP_TLS_DURATION`

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

In case you want to develop InspIRCd modules it is useful to run InspIRCd with modules which neither exist in core modules nor in extras.

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

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.
