#!/bin/sh
set -e
set -x

export STATIC_ROOT_LMS="/openedx/staticfiles"
export STATIC_ROOT_CMS=${STATIC_ROOT_LMS}/studio
export THEME_DIR="/openedx/themes"
export NODE_ENV=${NODE_ENV:-production}

cd /openedx/edx-platform
npm set progress=false
npm install --no-cache
grep -q ^export\ PATH=/openedx /etc/profile || echo export PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:\$\{PATH\}>>/etc/profile
PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:${PATH}

export NO_PREREQ_INSTALL=True
export NO_PYTHON_UNINSTALL=True
paver update_assets --settings derex.assets --themes open-edx "$1"

echo Symlinking files with the same content
symlink_duplicates.py "${STATIC_ROOT_LMS}"

# Avoid dulicates: rmlint finds files with the same conents, keeps the oldest
# and symlinks the other copies
rmlint -g -D -pp /openedx
# Do not remove empty files/directories
sed "/# empty /d" -i rmlint.sh
./rmlint.sh -d > /dev/null
