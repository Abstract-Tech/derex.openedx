#!/bin/sh
<<<<<<< HEAD

echo Downloading requirements ".in" file
curl -s https://raw.githubusercontent.com/edx/edx-platform/open-release/ironwood.master/requirements/edx/base.in \
    |grep -v "^-" \
    |sed "s/gunicorn[=><].*/gunicorn/" \
    > derex/openedx/wheels/base.in

echo Downloading constraints file
curl -s https://raw.githubusercontent.com/edx/edx-platform/open-release/ironwood.master/requirements/constraints.txt \
    |grep -v "^-" \
    |grep -v urllib3 `# transifex-client no longer needs this one pinned`\
    > derex/openedx/wheels/constraints.txt


[ -d .direnv/python-2.7 ] || (
    echo Creating python2.7 virtualenv
    mkdir -p .direnv
    virtualenv -p python2.7 .direnv/python-2.7
)
[ -x .direnv/python-2.7/bin/pip-compile ] || (
    echo Installing pip-tools
    .direnv/python-2.7/bin/pip install pip-tools
)
echo Running pip-compile
.direnv/python-2.7/bin/pip-compile --upgrade --quiet --no-header --no-emit-find-links derex/openedx/wheels/constraints.txt derex/openedx/wheels/base.in -o derex/openedx/wheels/requirements.txt
cp derex/openedx/wheels/requirements.txt derex/openedx/ironwood/requirements.txt
echo Done. Cleaning up.
rm derex/openedx/wheels/base.in
rm derex/openedx/wheels/constraints.txt
=======
EDX_PLATFORM_REPOSITORY=https://github.com/edx/edx-platform.git
EDX_PLATFORM_VERSION=open-release/ironwood.master

docker run --rm "$(derex.builder image derex/openedx/buildwheels/)" sh -c "
pip install -q pip==18.1 2> /dev/null
mkdir -p /openedx/themes /openedx/locale /openedx/bin/
git clone -q ${EDX_PLATFORM_REPOSITORY} --branch ${EDX_PLATFORM_VERSION} --depth 1 /openedx/edx-platform 2> /dev/null
cd /openedx/edx-platform

# pip-sync is confused by the latest version of matplotlib being only compatible with python 3
echo matplotlib==1.5.3 >> /openedx/edx-platform/requirements/constraints.txt

# AAARGHHH! WHY IS THIS FAILING, AND THIS NECESSARY??!!
echo edx-user-state-client==1.0.4 >> /openedx/edx-platform/requirements/constraints.txt
echo edx-ccx-keys==0.2.1 >> /openedx/edx-platform/requirements/constraints.txt

# paver.txt generation gives an error, but we do not use paver commands,
# so we leave it out
sed -e s@requirements/edx/paver@@ -i Makefile
sed -e 's/-r paver.txt//' -i requirements/edx/base.in
rm requirements/edx/paver.txt
# nor we need the testing  or development versions
sed /requirements.edx.testing/d -i Makefile
sed /requirements.edx.development/d -i Makefile
sed -e s@file:///openedx/edx-platform/@@ -i requirements/edx/*.txt
sed -e s@file:///openedx/edx-platform@.@ -i requirements/edx/*.txt
make upgrade > /dev/null 2> /dev/null
cat requirements/edx-sandbox/base.txt
" > derex/openedx/ironwood/requirements.txt
grep -v ^-e derex/openedx/ironwood/requirements.txt > derex/openedx/wheels/requirements.txt
>>>>>>> Upgrade versions and include script to do it
