#!/bin/sh

set -ex

ln -sf /openedx/edx-platform/lms/envs/derex/base.py /openedx/edx-platform/cms/envs/derex/

pip install pdbpp ipython
apk add vim

cd /openedx/edx-platform
npm set progress=false
npm install
