#!/bin/sh
set -ex

cd /openedx/edx-platform
export PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:${PATH}

export NO_PREREQ_INSTALL=True
export NO_PYTHON_UNINSTALL=True
paver update_assets --settings derex.assets
