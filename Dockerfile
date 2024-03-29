FROM ghcr.io/minchinweb/python:3.9

ARG DEBIAN_FRONTEND=noninteractive
ENV PYPICLOUD_VERSION=1.3.3

# Add an environment variable that pypicloud-uwsgi.sh uses to determine which
# user to run as
ENV UWSGI_USER abc

EXPOSE 8080

# includes init script and config for pypicloud
COPY root/ /

# Create a working directory for pypicloud
VOLUME /config

# # allow s6 to work with init script
# # https://github.com/just-containers/s6-overlay/issues/158#issuecomment-266913426
# # https://github.com/linuxserver/docker-sonarr/issues/28
# VOLUME ["/run"]

# Install packages required
RUN \
    apt update -qq && \
    echo "\n**** Apt installs ****" && \
    apt install --reinstall --no-install-recommends -y \
            libc-bin \
    && \
    apt install --no-install-recommends -y \
            gcc \
            libldap2-dev \
            libsasl2-dev \
            libmysqlclient-dev \
            # libffi-dev \
            libssl-dev \
            # bcrypt \
            wget \
    && \
    echo "\n**** Manuall Install of 'libffi' v6 ****" && \
    # only version 7 is availabe on Ubuntu focal (20.04)
    # for links --> https://packages.ubuntu.com/bionic/amd64/libffi6/download
        wget http://mirrors.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb  && \
        dpkg -i libffi6* && \
        rm libffi6* && \
    echo "\n**** Installing Python packages ****" && \
    pip install \
        pypicloud[all_plugins]==$PYPICLOUD_VERSION \
        requests \
        uwsgi \
        pastescript \
        mysqlclient \
        psycopg2-binary \
        # bcrypt \
    && \
    echo "\n**** Apt cleanup ****" && \
    apt remove -y \
            gcc \
            wget \
    && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Use the base image's init system.
CMD "/app/pypicloud-uwsgi.sh"


# these are provided by the build hook when run on Docker Hub
# need to be defined after the FROM statement to appear in the final image
ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG COMMIT="local-build"
ARG URL=""
ARG BRANCH="none"

LABEL maintainer="MinchinWeb" \
      org.label-schema.description="PyPI local server for Python packages" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url=${URL} \
      org.label-schema.vcs-ref=${COMMIT} \
      org.label-schema.schema-version="1.0.0-rc1"

ENV COMMIT_SHA=${COMMIT} \
    COMMIT_BRANCH=${BRANCH} \
    BUILD_DATE=${BUILD_DATE}
