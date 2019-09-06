#!/bin/sh
set -ex

PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:${PATH}

#rm -rvf /openedx/edx-platform/themes/[!p]*
compile_assets.sh
cleanup_assets.sh
symlink_duplicates.py /openedx/staticfiles
