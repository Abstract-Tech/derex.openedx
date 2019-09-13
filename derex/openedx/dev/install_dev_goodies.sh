#!/bin/sh

ln -sf /openedx/edx-platform/lms/envs/derex/base.py /openedx/edx-platform/cms/envs/derex/

pip install pdbpp ipython
apk add vim --no-cache
