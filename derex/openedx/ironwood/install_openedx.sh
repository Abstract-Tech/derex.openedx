#!/bin/sh
set -ex

EDX_PLATFORM_REPOSITORY=https://github.com/edx/edx-platform.git
EDX_PLATFORM_VERSION=open-release/ironwood.2

mkdir -p /openedx/themes /openedx/locale /openedx/bin/

git clone ${EDX_PLATFORM_REPOSITORY} --branch ${EDX_PLATFORM_VERSION} --depth 1 /openedx/edx-platform
cd /openedx/edx-platform

pip install --src /openedx/packages -r requirements/edx/base.txt
find /openedx/ -type d -name .git -exec rm -r {} +  # 70 Mb

# Copy the assets.py config file in place
mkdir /openedx/edx-platform/lms/envs/derex /openedx/edx-platform/cms/envs/derex
cp /tmp/assets.py /openedx/edx-platform/lms/envs/derex
echo > /openedx/edx-platform/lms/envs/derex/__init__.py
mv /tmp/assets.py /openedx/edx-platform/cms/envs/derex
echo > /openedx/edx-platform/cms/envs/derex/__init__.py

mv /tmp/wsgi.py /openedx/edx-platform/

# We prefer to do all tasks required for execution in advance,
# so we accept the additional 57 Mb this brings
python -m compileall /openedx  # +57 Mb
