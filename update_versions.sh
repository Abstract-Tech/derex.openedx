#!/bin/bash
set -e

EDX_PLATFORM_REPOSITORY=https://github.com/edx/edx-platform.git
EDX_PLATFORM_VERSION=open-release/ironwood.master

if [ ! -z "$PIP_TOOLS_CACHE" ]; then
    PIP_DOCKER_OPTION="-v $PIP_TOOLS_CACHE:/root/.cache/pip-tools"
fi
# shellcheck disable=SC2086
docker run $PIP_DOCKER_OPTION --rm "$(derex.builder image derex/openedx/buildwheels/)" sh -c "
git clone ${EDX_PLATFORM_REPOSITORY} --branch ${EDX_PLATFORM_VERSION} --depth 1 /openedx/edx-platform >&2
cd /openedx/edx-platform

# Copy the edx-sandbox matplotlib spec to edx/base.in
grep matplotlib requirements/edx-sandbox/base.in >> requirements/edx/base.in
grep matplotlib requirements/edx-sandbox/base.in >> requirements/constraints.txt

# These versions need to be pinned, otherwise they pull in an
# incompatible version of edx-opaque-keys
# Pinning versions that would otherwise result in incompatibilities
sed -i 's/edx-user-state-client.*/edx-user-state-client<=1.0.4/' requirements/edx/base.in
sed -i 's/edx-ccx-keys.*/edx-ccx-keys<=0.2.1/' requirements/edx/base.in
sed -i 's/edx-opaque-keys.*/edx-opaque-keys<1.0.0/' requirements/edx/base.in
sed -i 's/edx-opaque-keys.*/edx-opaque-keys<1.0.0/' requirements/edx/paver.in
sed -i 's/edx-milestones.*/edx-milestones<0.2.3/' requirements/edx/base.in
sed -i 's/edx-organizations.*/edx-organizations<2.1.0/' requirements/edx/base.in

# Solve ImportError: cannot import name LearningContextKeyField
sed -i 's/edx-completion.*/edx-completion<3.0.0/' requirements/edx/base.in

# Pin edx-drf-extensions to 2.4.2: newer version are incompatible with ironwood
sed -i 's/edx-drf-extensions.*/edx-drf-extensions==2.4.2/' requirements/edx/base.in

# Unpin urllib3: we don't use transifex client here
sed -i '/urllib3/d' requirements/constraints.txt

# Unpin gunicorn
sed -i 's/gunicorn.*/gunicorn/' requirements/edx/base.in

# fix ImportError: Module 'xmodule.modulestore.django' does not define a 'COURSE_PUBLISHED' attribute/class
sed -i 's/edx-when.*/edx-when<0.1.1/' requirements/edx/base.in
grep -q edx-when requirements/edx/base.in || echo 'edx-when<0.1.1' >> requirements/edx/base.in
sed -i 's/pdfminer.*/pdfminer.six==20191020/' requirements/edx/base.in
sed -i 's/edx-proctoring>=1.5.3.*/edx-proctoring>=1.5.3,<=1.6.2/' requirements/edx/base.in


# We don't need the testing or development versions, so we can speed up the
# process by removing them
sed /requirements.edx.testing/d -i Makefile
sed /requirements.edx.development/d -i Makefile

# Document this command to update versions
sed -i s/CUSTOM_COMPILE_COMMAND=.*/CUSTOM_COMPILE_COMMAND='.\\/update_versions.sh'/ Makefile

# scripts/post-pip-compile.sh specifies bash in its shebang. Make sure it's present
apk add bash >&2

# Upgrade pip-tools before running make
pip install pip-tools >&2
pip-compile -v --no-emit-trusted-host --no-index --upgrade -o requirements/edx/pip-tools.txt requirements/edx/pip-tools.in >&2

# This is our goal: all these preparations were just so we could run this
make upgrade >&2

cat requirements/edx/base.txt
" > derex/openedx/nostatic/requirements_all.txt

sed -e s@file:///openedx/edx-platform/@@ -i derex/openedx/nostatic/requirements_all.txt
sed -e s@file:///openedx/edx-platform@.@ -i derex/openedx/nostatic/requirements_all.txt
sed 's/^-e git/git/' -i derex/openedx/nostatic/requirements_all.txt
echo "--find-links http://pypi.abzt.de/alpine-3.10" >> derex/openedx/nostatic/requirements_all.txt
echo "--trusted-host pypi.abzt.de" >> derex/openedx/nostatic/requirements_all.txt
grep -E -v '^-e|^git.https://' derex/openedx/nostatic/requirements_all.txt > derex/openedx/wheels/requirements.txt
grep -E '^-e|^git.https://' derex/openedx/nostatic/requirements_all.txt > derex/openedx/nostatic/requirements.txt
