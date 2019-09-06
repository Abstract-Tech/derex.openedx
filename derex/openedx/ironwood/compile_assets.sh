#!/bin/sh
set -e
set -x

export FINAL_STATIC_ROOT="/openedx/staticfiles"
export STATIC_ROOT_LMS="/tmp/staticfiles"
export STATIC_ROOT_CMS=${STATIC_ROOT_LMS}/studio
export THEME_DIR="/openedx/themes"
export NODE_ENV=${NODE_ENV:-production}

[ -x /usr/bin/node ] || apk add nodejs --no-cache
[ -x /usr/bin/npm ] || apk add npm --no-cache
[ -x /usr/bin/rsync ] || apk add rsync --no-cache
[ -x /usr/bin/make ] || apk add make --no-cache
[ -x /usr/bin/g++ ] || apk add g++ --no-cache

cd /openedx/edx-platform
npm set progress=false
npm install
grep -q ^export\ PATH=/openedx /etc/profile || echo export PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:\$\{PATH\}>>/etc/profile
PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:${PATH}

export NO_PREREQ_INSTALL=True
export NO_PYTHON_UNINSTALL=True
if [ -z "$1" ]; then
    THEMES=open-edx
else
    THEMES="$1"
fi
paver update_assets --settings derex.assets --themes "$THEMES"

echo Symlinking files with the same content
symlink_duplicates.py "${STATIC_ROOT_LMS}"

echo Rsync assets in place to avoid replacing the same file
# Careful to include a trailing slash for the source dir: rsync is sensitive to this
rsync --delete -a "${STATIC_ROOT_LMS}"/ "${FINAL_STATIC_ROOT}"

# Cleanup is done in cleanup_assets.sh, but we remove /tmp/staticfiles here
rm -rf /tmp/staticfiles
