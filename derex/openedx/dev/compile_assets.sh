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

export NO_PREREQ_INSTALL=True
export NO_PYTHON_UNINSTALL=True
paver update_assets --settings derex.assets --themes open-edx "$1"
