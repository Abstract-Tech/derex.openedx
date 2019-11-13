#!/bin/sh
set -ex
VERSION=3.8.0
WORKDIR=/tmp
cd ${WORKDIR}
wget -c http://download.osgeo.org/geos/geos-${VERSION}.tar.bz2
tar xf geos-${VERSION}.tar.bz2
cd geos-${VERSION}
docker run -v "${PWD}:/geos" --rm alpine:3.10.3 sh -c "
    apk add alpine-sdk
    cd /geos
    ./configure
    make"
CAPI_VERSION=$(grep CAPI_VERSION\ = Makefile|sed 's/.*= //')
LIBPATH=${WORKDIR}/geos-${VERSION}/capi/.libs/libgeos_c.so.${CAPI_VERSION}

swift upload --object-name "/alpine-3.10/libgeos_c/libgeos_c.so.${CAPI_VERSION}" pypi "${LIBPATH}"

# Can be tested with
# python -c "from ctypes import CDLL; CDLL('${LIBPATH}').GEOSversion"
