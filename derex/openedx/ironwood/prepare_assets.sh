#!/bin/sh
set -ex

PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:${PATH}

compile_assets.sh
cleanup_assets.sh
