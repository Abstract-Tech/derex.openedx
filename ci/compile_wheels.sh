#!/bin/sh

set -ex

EDX_PLATFORM_REPOSITORY=${EDX_PLATFORM_REPOSITORY-https://github.com/edx/edx-platform.git}
IMAGE=$(derex.builder image derex/openedx/buildwheels)

docker run -v /tmp/wheelhouse:/wheelhouse -v "${PIP_CACHE}:/root/.cache/pip" -d --name derex.wheel.compiler --rm "$IMAGE" sleep 86400

docker exec derex.wheel.compiler git clone "$EDX_PLATFORM_REPOSITORY" --branch "${EDX_PLATFORM_VERSION}" --depth 1
docker exec derex.wheel.compiler pip install wheel

docker exec derex.wheel.compiler sh -c "
egrep -v '^-e|^git' edx-platform/requirements/edx/base.txt > base_external.txt
echo '--find-links http://pypi.abzt.de/alpine-3.10' >> base_external.txt
echo '--trusted-host pypi.abzt.de' >> base_external.txt
pip install numpy -c base_external.txt --find-links http://pypi.abzt.de/alpine-3.10
pip wheel --wheel-dir=/wheelhouse -r base_external.txt --find-links http://pypi.abzt.de/alpine-3.10
"

docker kill derex.wheel.compiler
