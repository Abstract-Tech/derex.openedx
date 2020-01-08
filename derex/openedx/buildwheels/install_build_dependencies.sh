#!/bin/sh
set -e
set -x

DOCKERIZE_VERSION=v0.6.1
wget -q -O - "https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" | tar xzf - --directory /usr/local/bin

echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

apk add \
    freetype-dev \
    g++ \
    gcc \
    gettext \
    gfortran \
    graphviz-dev \
    jpeg-dev \
    lapack-dev \
    libffi-dev \
    libpng-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    make \
    mariadb-connector-c-dev \
    mariadb-dev \
    openblas-dev \
    pkgconfig \
    python-dev \
    sqlite-dev \
    swig \
    xmlsec-dev

# From https://github.com/jfloff/alpine-python/issues/32
sed '/st_mysql_options options;/a unsigned int reconnect;' /usr/include/mysql/mysql.h -i
