#!/bin/sh
set -e
set -x

DOCKERIZE_VERSION=v0.6.1
wget -q -O - "https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" | tar xzf - --directory /usr/local/bin

apk add \
    gettext \
    git \
    graphviz \
    freetype \
    graphviz \
    lapack \
    libstdc++ \
    libjpeg \
    libxslt \
    mariadb-connector-c \
    sqlite \
    xmlsec

# Libgeos compiled with the command `compile_geos.sh`
wget http://pypi.abzt.de/alpine-3.10/libgeos_c/libgeos_c.so.1.13.1 -O /usr/lib/libgeos_c.so.1.13.1
ln -s libgeos_c.so.1.13.1 /usr/lib/libgeos_c.so
wget http://pypi.abzt.de/alpine-3.10/libs/libgeos-3.8.0.so -O /usr/lib/libgeos-3.8.0.so


# To force a rebuild of the image change the following
# Last edited: 2019-11-12
date > /etc/base_image_build_time
