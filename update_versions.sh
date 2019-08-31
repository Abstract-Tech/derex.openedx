#!/bin/sh
EDX_PLATFORM_REPOSITORY=https://github.com/edx/edx-platform.git
EDX_PLATFORM_VERSION=open-release/ironwood.master

docker run --rm "$(derex.builder image derex/openedx/buildwheels/)" sh -c "
pip install -q pip==18.1 2> /dev/null
git clone -q ${EDX_PLATFORM_REPOSITORY} --branch ${EDX_PLATFORM_VERSION} --depth 1 /openedx/edx-platform 2> /dev/null
cd /openedx/edx-platform

# pip-sync is confused by the latest version of matplotlib being only compatible with python 3
echo matplotlib==1.5.3 >> /openedx/edx-platform/requirements/constraints.txt

# AAARGHHH! WHY IS THIS FAILING, AND THIS NECESSARY??!!
#echo edx-user-state-client==1.0.4 >> /openedx/edx-platform/requirements/constraints.txt
#echo edx-ccx-keys==0.2.1 >> /openedx/edx-platform/requirements/constraints.txt

# We don't need the testing or development versions
#sed /requirements.edx.testing/d -i Makefile
#sed /requirements.edx.development/d -i Makefile

# xmodule requires a version of edx-opaque-keys<1.0.0
# and messes with edx-ccx-keys version requirements
# that requires edx-opaque-keys>=1.0.1,<2.0.0
# It's being discontinued, so we omit it
sed /common.lib.xmodule/d -i requirements/edx/local.in

# Isn't base.txt supposed to be about to be regenerated?
# Why is it being looked into?
sed /python-slugify/d -i requirements/edx/base.txt

apk add bash -q

make upgrade > /dev/null 2> /dev/null
# The first time it uses an older version of pip-tools
# and errors out
make upgrade > /dev/null 2> /dev/null
sed -e s@file:///openedx/edx-platform/@@ -i requirements/edx/*.txt
sed -e s@file:///openedx/edx-platform@.@ -i requirements/edx/*.txt
cat requirements/edx-sandbox/base.txt
" > derex/openedx/ironwood/requirements.txt
grep -v ^-e derex/openedx/ironwood/requirements.txt > derex/openedx/wheels/requirements.txt
