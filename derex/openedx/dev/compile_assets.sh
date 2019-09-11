#!/bin/sh
set -e
set -x

export STATIC_ROOT_LMS="/openedx/staticfiles"
export STATIC_ROOT_CMS=${STATIC_ROOT_LMS}/studio
export THEME_DIR="/openedx/themes"
export NODE_ENV=${NODE_ENV:-production}

[ -x /usr/bin/node ] || apk add nodejs --no-cache
[ -x /usr/bin/npm ] || apk add npm --no-cache
[ -x /usr/bin/make ] || apk add make --no-cache
[ -x /usr/bin/g++ ] || apk add g++ --no-cache

cd /openedx/edx-platform
npm set progress=false
npm install
grep -q ^export\ PATH=/openedx /etc/profile || echo export PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:\$\{PATH\}>>/etc/profile
PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:${PATH}

export NO_PREREQ_INSTALL=True
export NO_PYTHON_UNINSTALL=True
paver update_assets --settings derex.assets --themes open-edx "$1"

echo Symlinking files with the same content
symlink_duplicates.py "${STATIC_ROOT_LMS}"

# Cleanup is done in cleanup_assets.sh, but we remove /tmp/staticfiles here
rm -rf /tmp/staticfiles