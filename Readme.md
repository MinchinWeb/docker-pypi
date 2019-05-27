# PyPI Server

*[PyPI](https://pypi.org/)* (aka the *Python Package Index*) is the public
service that provides access to packaged Python code. This Docker image
provides a locally install implementation. It has two obvious use-cases: 1) to
act as a local (and thus faster) mirror of the official PyPI (with the option
to cache requested packages on the fly), and 2) to provide a private location
to publish Python packages (e.g. for internal projects).

Under the hood, this is using
[PyPICloud](https://pypicloud.readthedocs.io/en/latest/).

[![Docker Pulls](https://img.shields.io/docker/pulls/minchinweb/pypi.svg?style=popout)](https://hub.docker.com/r/minchinweb/pypi)
[![Size & Layers](https://images.microbadger.com/badges/image/minchinweb/pypi.svg)](https://microbadger.com/images/minchinweb/pypi)
[![GitHub issues](https://img.shields.io/github/issues-raw/minchinweb/docker-pypi.svg?style=popout)](https://github.com/MinchinWeb/docker-pypi/issues)
<!--
![MicroBadger Layers](https://img.shields.io/microbadger/layers/layers/minchinweb/pypi.svg?style=plastic)
![MicroBadger Size](https://img.shields.io/microbadger/image-size/image-size/minchinweb/pypi.svg?style=plastic)
-->

## How to Use This

### Docker Setup

The container is designed to be used directly. Here is a portion of my personal
'docker-compose.yaml' file:

    services:
      # many others...

      pypi:
        image: minchinweb/pypi
        restart: unless-stopped
        environment:
          - PUID=${PUID}
          - PGID=${PGID}
        ports:
          - 6543:8080
        volumes:
          - ${DOCKER_USERDIR}/volumes/pypi/:/config


`PUID`, `GUID`, and `DOCKER_USERDIR` are environmental variables used by
service services in my local stack, and are provided by a `.env` file located
in the same directory as my `docker-compose.yaml` file. That said, none of
these are absolutely required, as (hopefully) useful defaults have been
provided.

### PyPICloud Configuration

If you map `/config` (which is probably what you want), you'll need to provide
a `config.ini` file in that directory. The [default
configuration](https://github.com/MinchinWeb/docker-pypi/blob/master/root/config/config.ini)
can be used as is (although you have to copy it in place). The [PyPICloud
documentation](https://pypicloud.readthedocs.io/en/latest/topics/configuration.html)
will be useful if you want to customize it. In particular, it has options to
use cloud storage for Python packages you are hosting or to use a "full"
database (rather than the default of SQLite) for caching your list of available
packages.

Personally, the only option I changed from the default was to add
`pypi.fallback = cache`, which will cause packages to be downloaded from the
main PyPI and then cached the first time they are requested.

### Local Web Configuration

Under the provided configuration, you need to log in to actually download any
packages. Go to the web address, and the first time you do, it will ask you to
create an admin user. Log in with this admin user to create other users and
manually download other packages.

The web address (once logged in) will show you the `pip` command to use to
download packages from here.

### Local (per machine) Pip Configuration

Pip can be configured with an extra URL to search for packages. By setting this
up, `pip` will automatically make use for your private PyPI server. First
determine where your [`pip.conf` file is on
disk](https://pip.pypa.io/en/stable/user_guide/#configuration). To use your
local server alone, add the following to your `pip.conf`:

    [global]
    index-url = http://localhost:6543/simple/

**Note**: Adjust the URL to match the hostname of the machine you're running
Docker on, and the port to match what you set in the `docker-compose.yaml`
above.

**Note 2**: Using `index-url` (as above, in your `pip.conf`) is going to make
your server the only place `pip` will look for packages, and thus if you're
server is down, `pip` won't work. *pypicloud* is set to either (by default)
forward to or (with the `pypi.fallback = cache` in `/config/config.ini`) cache
from the Global PyPI, so you'll still have access to all packages. If you are
just hosting private packages, you may want to use the `extra-index-url`
setting in your `pip.conf` instead.

To upload, you will need to update your `.pypirc` file (typically at
`$HOME/.pypirc`)

    [pypicloud]
    repository: http://localhost:6543/simple/
    username: [username]
    password: [password]

Again, the URL will likely need to be adjusted. Usernames and passwords can be
set on the Web UI.

## Why I Created This

or, *What Problems is This Trying to Solve?*

Because I could? (I always think that's a valid reason!)

For me, I like the idea of having a local backup copy of certain Python
packages.

Also, it provided a real-world use of my [Python base
image](https://github.com/MinchinWeb/docker-python).


## Prior Art

This wouldn't work with the
[PyPICloud](https://pypicloud.readthedocs.io/en/latest/) project. It is also
built on my [Python base image](https://github.com/MinchinWeb/docker-python).

Steven Arcangeli's [docker-ized version of
PyPICloud](https://github.com/stevearc/pypicloud-docker) were used as an
inspiration and a model for creating this image. (Steven is also the creator of
PyPICloud.)

The `/sbin/setuser` script is cribbed from [Phusion's base
image](http://phusion.github.io/baseimage-docker/).


## Known Issues

- you'll need to log in via the WebUI once the image is first up to create a
  user
- by default, you need to have a user account (and then provider the username
  and password when you run `pip`); if you want, you can adjust the settings to
  allow anonymous downloads.
- the favicon will return a 404 error
