#!/bin/sh

EDX_PLATFORM_REPOSITORY=${EDX_PLATFORM_REPOSITORY-https://github.com/edx/edx-platform.git}
IMAGE=$(derex.builder image derex/openedx/buildwheels)

echo "Building image (if necessary)"
derex.builder resolve derex/openedx/buildwheels

docker run -v "${PIP_CACHE}:/root/.cache/pip" -d --name derex.wheel.compiler --rm "$IMAGE" sleep 86400

docker exec derex.wheel.compiler git clone "$EDX_PLATFORM_REPOSITORY" --branch "${EDX_PLATFORM_VERSION}" --depth 1
docker exec derex.wheel.compiler pip install wheel
edx-platform/requirements/edx/base.txt
docker exec derex.wheel.compiler sh -c "
egrep -v '^-e|^git' edx-platform/requirements/edx/base.txt > base_external.txt
echo '--find-links http://pypi.abzt.de/alpine-3.10' >> base_external.txt
mkdir /wheelhouse
pip wheel --wheel-dir=/wheelhouse -r base_external.txt
"

#docker kill derex.wheel.compiler
