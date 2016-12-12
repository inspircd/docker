# InspIRCd

InspIRCd is a modular Internet Relay Chat (IRC) server written in C++ for Linux, BSD, Windows and Mac OS X systems which was created from scratch to be stable, modern and lightweight.

InspIRCd is one of only a few IRC servers to provide a tunable number of features through the use of an advanced but well documented module system. By keeping core functionality to a minimum we hope to increase the stability, security and speed of InspIRCd while also making it customisable to the needs of many different users.

# How to use this image

First, a simple run command:

```console
$ docker run --name ircd -p 6667:6667 inspircd/inspircd-docker
```

This will start an inspircd instance listening on the default irc port 6667 on the container.

To configure include your configuration into the container use:

```console
$ docker run --name inspircd -p 6667:6667 -v /path/to/your/config:/inspircd/conf/ inspircd/inspircd-docker
```

*Notice: In case you provide an empty directory make sure it's owned by uid 10000. Use `chown 10000 directory` to correct permissions*

Default ports of this container:

|Port|config            |
|----|------------------|
|6667|clients, plaintext|
|6697|clients, tls      |
|7000|server, plaintext |
|7001|server, tls       |

## TLS

This container generates a self-signed TLS certificate on startup as long as none exists. To use this container with TLS enabled:

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


# Build extras

To build extra modules you can use the `--build-arg` statement.

Available build arguments:

|Argument|Description                                              |
|--------|---------------------------------------------------------|
|VERSION |Version of InspIRCd. Uses `-b`-parameter from `git clone`|
|CONFIGUREARGS|Additional Parameters. Used to enable core extras like `m_geoip.cpp`|
|EXTRASMODULES|Additional Modules from [inspircd-extras](https://github.com/inspircd/inspircd-extras/tree/master/2.0) repository like `m_geoipban`|
|ADDPACKAGES|Additional packages which are installed before compilation|
|DELPACKAGES|Additional packages which are deleted after compilation|

```console
docker build --build-arg "ADDPACKAGES=geoip geoip-dev pcre-dev pcre" --build-arg "CONFIGUREARGS=--enable-extras=m_geoip.cpp --enable-extras=m_regex_pcre.cpp"  --build-arg "EXTRASMODULES=m_geoipban" inspircd-docker
```

# License

View [license information](https://github.com/inspircd/inspircd) for the software contained in this image.

# Supported Docker versions

This image is officially supported on Docker version 1.12.3.

Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker daemon.

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/Adam-/inspircd-docker/issues).

You can also reach many of the project maintainers via the `#inspircd` IRC channel on [Chatspike](https://chatspike.net).

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.
