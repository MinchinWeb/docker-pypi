FROM minchinweb/python

ARG DEBIAN_FRONTEND=noninteractive
ENV PYPICLOUD_VERSION 1.0.11

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
    apt install --no-install-recommends -y \
            gcc \
            libldap2-dev \
            libsasl2-dev \
            libmysqlclient-dev \
            libffi-dev \
            libssl-dev \
    && \
    echo "\n**** Installing Python packages ****" && \
    pip install \
        pypicloud[all_plugins]==$PYPICLOUD_VERSION \
        requests \
        uwsgi \
        pastescript \
        mysqlclient \
        psycopg2-binary \
    && \
    echo "\n**** Apt cleanup ****" && \
    apt remove -y \
            gcc \
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
      org.label-schema.description="Personal base image, based on Ubuntu" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url=${URL} \
      org.label-schema.vcs-ref=${COMMIT} \
      org.label-schema.schema-version="1.0.0-rc1"

ENV COMMIT_SHA=${COMMIT} \
    COMMIT_BRANCH=${BRANCH} \
    BUILD_DATE=${BUILD_DATE}
