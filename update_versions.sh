#!/bin/bash
EDX_PLATFORM_REPOSITORY=https://github.com/edx/edx-platform.git
EDX_PLATFORM_VERSION=open-release/ironwood.master

if [ ! -z "$PIP_CACHE" ]; then
    PIP_DOCKER_OPTION="-v $PIP_CACHE:/root/.cache/pip"
fi
# shellcheck disable=SC2086
docker run $PIP_DOCKER_OPTION --rm "$(derex.builder image derex/openedx/buildwheels/)" sh -c "
pip install pip==18.1 >&2
git clone ${EDX_PLATFORM_REPOSITORY} --branch ${EDX_PLATFORM_VERSION} --depth 1 /openedx/edx-platform >&2
cd /openedx/edx-platform

# pip-sync is confused by the latest version of matplotlib being only compatible with python 3
echo 'matplotlib<3.0.0' >> requirements/edx/base.in
echo 'matplotlib<3.0.0' >> requirements/constraints.txt

# These versions need to be pinned, otherwise they pull in an
# incompatible version of edx-opaque-keys
# Pinning versions that would otherwise result in incompatibilities
sed -i 's/edx-user-state-client.*/edx-user-state-client<=1.0.4/' requirements/edx/base.in
sed -i 's/edx-ccx-keys.*/edx-ccx-keys<=0.2.1/' requirements/edx/base.in
sed -i 's/edx-opaque-keys.*/edx-opaque-keys<1.0.0/' requirements/edx/base.in
sed -i 's/edx-opaque-keys.*/edx-opaque-keys<1.0.0/' requirements/edx/paver.in
sed -i 's/edx-milestones.*/edx-milestones<0.2.3/' requirements/edx/base.in
sed -i 's/edx-organizations.*/edx-organizations<2.1.0/' requirements/edx/base.in
edx-milestones
# We don't need the testing or development versions, so we can speed up the
# process by removing them
sed /requirements.edx.testing/d -i Makefile
sed /requirements.edx.development/d -i Makefile

apk add bash >&2

# Upgrade pip-tools befor running make
pip install -r requirements/edx/pip-tools.txt >&2
pip-compile -v --no-emit-trusted-host --no-index --upgrade -o requirements/edx/pip-tools.txt requirements/edx/pip-tools.in >&2

# Install our numpy version. Otherwise 'python setup.py egg_info' (run by pip-compile)
# fails for matplotlib
pip install \$(grep numpy requirements/edx/base.in|awk '{print $1}') >&2

# Document this command to update versions
export CUSTOM_COMPILE_COMMAND='./update_versions.sh'

# This is our goal: all these preparations were just so we could run this
make upgrade >&2

sed -e s@file:///openedx/edx-platform/@@ -i requirements/edx/*.txt
sed -e s@file:///openedx/edx-platform@.@ -i requirements/edx/*.txt
sed -e 's@-e git+https://@git+https://@' -i requirements/edx/*.txt
cat requirements/edx-sandbox/base.txt
" > derex/openedx/ironwood/requirements.txt

grep -E -v '^-e|^git.https://' derex/openedx/ironwood/requirements.txt > derex/openedx/wheels/requirements.txt
