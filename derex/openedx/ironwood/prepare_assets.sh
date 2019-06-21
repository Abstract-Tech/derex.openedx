#!/bin/sh
set -ex

PATH=/openedx/edx-platform/node_modules/.bin:/openedx/nodeenv/bin:/openedx/bin:${PATH}

rm -rf /openedx/edx-platform/themes/*
compile_assets.sh
cleanup_assets.sh
symlink_duplicates.py /openedx/staticfiles
