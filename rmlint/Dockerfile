FROM python:2.7-alpine3.10 as build

RUN pip install scons && \
  apk add \
    alpine-sdk \
    gettext \
    git \
    glib-dev \
    json-glib


RUN wget -q https://github.com/sahib/rmlint/tarball/develop -O - | tar xvzf - && \
    cd sahib-rmlint* && \
    scons && \
    cp rmlint /usr/local/bin/

FROM python:2.7-alpine3.10
COPY --from=build /usr/local/bin/rmlint /usr/local/bin/rmlint
