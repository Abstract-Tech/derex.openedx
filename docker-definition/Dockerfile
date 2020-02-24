# syntax = docker/dockerfile:experimental
FROM docker.io/python:3.6-alpine3.11 as libgeos

RUN --mount=type=cache,target=/var/cache/apk apk add \
    alpine-sdk
ENV GEOS_VERSION=3.8.0

RUN wget -c http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 -O - | tar xjf - --directory /usr/local
WORKDIR /usr/local/geos-${GEOS_VERSION}
RUN ./configure && make -j 4
RUN make install

FROM docker.io/python:3.6-alpine3.11 as base
ENV GEOS_VERSION=3.8.0

RUN wget -q -O - "https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz" | tar xzf - --directory /usr/local/bin

RUN --mount=type=cache,target=/var/cache/apk apk add \
    gettext \
    git \
    graphviz \
    freetype \
    graphviz \
    openblas \
    lapack \
    libstdc++ \
    libjpeg \
    libxslt \
    mariadb-connector-c \
    sqlite \
    xmlsec

COPY --from=libgeos /usr/local/lib/libgeos* /usr/lib/
# Test that it works
RUN python -c "from  ctypes import CDLL; CDLL('$(echo /usr/lib/libgeos_c.so)').GEOSversion"
RUN date > /etc/base_image_build_time

COPY patch_ldconfig_to_fix_shapely.sh /tmp/patch_ldconfig_to_fix_shapely.sh

RUN /tmp/patch_ldconfig_to_fix_shapely.sh

FROM base as builder

RUN --mount=type=cache,target=/var/cache/apk apk add \
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
RUN sed '/st_mysql_options options;/a unsigned int reconnect;' /usr/include/mysql/mysql.h -i

FROM base as sourceonly

ENV EDX_PLATFORM_REPOSITORY=https://github.com/edx/edx-platform.git
ENV EDX_PLATFORM_VERSION=open-release/juniper.alpha1

RUN mkdir -p /openedx/themes /openedx/locale /openedx/bin/ && \
    git clone ${EDX_PLATFORM_REPOSITORY} --branch ${EDX_PLATFORM_VERSION} --depth 1 /openedx/edx-platform

WORKDIR /openedx/edx-platform

FROM builder as wheels

RUN --mount=type=cache,target=/root/.cache/pip --mount=type=bind,source=/openedx,from=sourceonly,target=/openedx \
    cat /openedx/edx-platform/requirements/edx/base.txt | grep -v github | grep -v ^-e > /tmp/requirements_derex.txt && \
    pip wheel --find-links http://pypi.abzt.de/alpine-3.11 --trusted-host pypi.abzt.de --wheel-dir=/wheelhouse -r /tmp/requirements_derex.txt

FROM sourceonly as nostatic

RUN --mount=type=cache,target=/root/.cache/pip pip install whitenoise==4.1.3 flower==0.9.3 tornado==5.1.1 backports_abc==0.5
RUN --mount=type=cache,target=/root/.cache/pip --mount=type=bind,source=/wheelhouse,from=wheels,target=/wheelhouse \
    pip install --trusted-host pypi.abzt.de --find-links http://pypi.abzt.de/alpine-3.11 --find-links /wheelhouse -r /openedx/edx-platform/requirements/edx/base.txt

FROM nostatic as nostatic-dev

RUN --mount=type=cache,target=/var/cache/apk apk add npm nodejs g++ make coreutils vim
WORKDIR /openedx/edx-platform
RUN --mount=type=cache,target=/root/.npm npm install

# Also install dev utilities
RUN --mount=type=cache,target=/root/.cache/pip pip install pdbpp ipython ipdb

FROM nostatic-dev as dev
RUN mkdir -p /openedx/edx-platform/lms/envs/derex /openedx/edx-platform/cms/envs/derex && \
    touch /openedx/edx-platform/lms/envs/derex/__init__.py /openedx/edx-platform/cms/envs/derex/__init__.py


COPY compile_assets.sh /usr/local/bin
COPY assets.py /openedx/edx-platform/lms/envs/derex
COPY assets.py /openedx/edx-platform/cms/envs/derex
RUN /usr/local/bin/compile_assets.sh
