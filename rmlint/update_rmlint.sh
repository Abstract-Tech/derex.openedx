#!/bin/sh

DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
docker build "${DIR}" -t derex/rmlint
docker run -v "${DIR}"/../derex/openedx/nostatic:/dest --rm derex/rmlint cp /usr/local/bin/rmlint /dest/
