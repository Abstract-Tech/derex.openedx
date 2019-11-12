#!/bin/sh
set -e
set -x

DOCKERIZE_VERSION=v0.6.1
wget -q -O - "https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" | tar xzf - --directory /usr/local/bin

echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

apk add \
    geos-dev@testing \
    gettext \
    git \
    graphviz \
    freetype \
    graphviz \
    lapack \
    libjpeg \
    libxslt \
    mariadb-connector-c \
    sqlite \
    xmlsec

# To force a rebuild of the image change the following
# Last edited: 2019-11-12
date > /etc/base_image_build_time
