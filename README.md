# InspIRCd

InspIRCd is a modular Internet Relay Chat (IRC) server written in C++ for Linux, BSD, Windows and Mac OS X systems which was created from scratch to be stable, modern and lightweight.

As InspIRCd is one of the few IRC servers written from scratch, it avoids a number of design flaws and performance issues that plague other more established projects, such as UnrealIRCd, while providing the same level of feature parity.

InspIRCd is one of only a few IRC servers to provide a tunable number of features through the use of an advanced but well documented module system. By keeping core functionality to a minimum we hope to increase the stability, security and speed of InspIRCd while also making it customisable to the needs of many different users.

# How to use this image

First, a simple run command:

```console
$ docker run --name ircd -p 6667:6667 inspircd/inspircd
```

This will start an inspircd instance listening on the default irc port 6667 on the container.

To configure include your configuration into the container use:

```console
$ docker run --name inspircd -p 6667:6667 -v /path/to/your/config:/inspircd/conf/ inspircd/inspircd
```

# Build extras

To build extra modules you can use the `--build-arg` statement.

```console
docker build --build-arg "ADDPACKAGES=geoip geoip-dev pcre-dev pcre" --build-arg "CONFIGUREARGS=--enable-extras=m_geoip.cpp --enable-extras=m_regex_pcre.cpp" docker-inspircd
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
