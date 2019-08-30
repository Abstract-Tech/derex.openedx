#!/bin/sh

echo Downloading requirements ".in" file
curl -s https://raw.githubusercontent.com/edx/edx-platform/open-release/ironwood.master/requirements/edx/base.in \
    |grep -v "^-" \
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
.direnv/python-2.7/bin/pip-compile --Upgrade --quiet --no-header --no-emit-find-links derex/openedx/wheels/constraints.txt derex/openedx/wheels/base.in -o derex/openedx/wheels/requirements.txt
echo Done. Cleaning up.
rm derex/openedx/wheels/base.in
rm derex/openedx/wheels/constraints.txt
