#!/bin/sh
set -ex

EDX_PLATFORM_REPOSITORY=https://github.com/edx/edx-platform.git
EDX_PLATFORM_VERSION=open-release/juniper.alpha1

mkdir -p /openedx/themes /openedx/locale /openedx/bin/

git clone ${EDX_PLATFORM_REPOSITORY} --branch ${EDX_PLATFORM_VERSION} --depth 1 /openedx/edx-platform
cd /openedx/edx-platform

# Use our updated requirements file
cp /tmp/requirements.txt requirements/edx/requirements_derex.txt
pip install --src /openedx/packages -r requirements/edx/requirements_derex.txt

# Copy the base.py and assets.py config file in place
mkdir /openedx/edx-platform/lms/envs/derex /openedx/edx-platform/cms/envs/derex
mv /tmp/assets.py /openedx/edx-platform/lms/envs/derex
mv /tmp/base.py /openedx/edx-platform/lms/envs/derex
echo > /openedx/edx-platform/lms/envs/derex/__init__.py
ln -s /openedx/edx-platform/lms/envs/derex/*.py /openedx/edx-platform/cms/envs/derex

mv /tmp/wsgi.py /openedx/edx-platform/
mv /tmp/edx_celery.py /openedx/edx-platform/

# We prefer to do all tasks required for execution in advance,
# so we accept the additional 57 Mb this brings
python -m compileall -q /openedx  # +57 Mb

# Download updated translations from transifex
/openedx/bin/translations.sh
