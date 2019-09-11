#!/bin/sh
set -ex

pip install whitenoise==4.1.3

mv /tmp/restore_dump.py /openedx/bin/

mv /tmp/fixtures /openedx/
