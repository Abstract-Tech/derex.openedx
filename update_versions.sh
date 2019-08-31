#!/bin/sh
EDX_PLATFORM_REPOSITORY=https://github.com/edx/edx-platform.git
EDX_PLATFORM_VERSION=open-release/ironwood.master

docker run --rm "$(derex.builder image derex/openedx/buildwheels/)" sh -c "
pip install pip==18.1 >&2
git clone ${EDX_PLATFORM_REPOSITORY} --branch ${EDX_PLATFORM_VERSION} --depth 1 /openedx/edx-platform >&2
cd /openedx/edx-platform

# pip-sync is confused by the latest version of matplotlib being only compatible with python 3
#echo 'matplotlib<3.0.0' >> requirements/edx/base.in
echo 'matplotlib==1.5.3' >> requirements/edx/base.in


# AAARGHHH! WHY IS THIS FAILING, AND THIS NECESSARY??!!
# Pinning versions that would otherwise result in incompatibilities
sed /edx-user-state-client/d -i requirements/edx/paver.in
echo 'edx-user-state-client<=1.0.4' >> requirements/edx/base.in
sed /edx-ccx-keys/d -i requirements/edx/paver.in
echo 'edx-ccx-keys<=0.2.1' >> requirements/edx/base.in
sed /edx-opaque-keys/d -i requirements/edx/paver.in
echo 'edx-opaque-keys<1.0.0' >> requirements/edx/paver.in
# We don't need the testing or development versions
sed /requirements.edx.testing/d -i Makefile
sed /requirements.edx.development/d -i Makefile

apk add bash >&2

# Upgrade pip-tools befor running make
pip install -r requirements/edx/pip-tools.txt >&2
pip-compile -v --no-emit-trusted-host --no-index --upgrade -o requirements/edx/pip-tools.txt requirements/edx/pip-tools.in
# Install our numpy version. Otherwise 'python setup.py egg_info' (run by pip-compile)
# fails for matplotlib
pip install $(grep numpy  requirements/edx/base.in|awk '{print $1}') >&2
make upgrade >&2
sed -e s@file:///openedx/edx-platform/@@ -i requirements/edx/*.txt
sed -e 's@-e git+https://@git+https://@' -i requirements/edx/*.txt
cat requirements/edx-sandbox/base.txt
" > derex/openedx/ironwood/requirements.txt
grep -v ^-e derex/openedx/ironwood/requirements.txt > derex/openedx/wheels/requirements.txt
