#!/bin/sh

pip install whitenoise==4.1.2

mkdir /openedx/edx-platform/lms/envs/derex
mv /tmp/base.py /openedx/edx-platform/lms/envs/derex/
ln -s /openedx/edx-platform/lms/envs/derex/base.py /openedx/edx-platform/cms/envs/derex/
mv /tmp/restore_dump.py /openedx/bin/

mv /tmp/fixtures /openedx/
