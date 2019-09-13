#!/bin/sh
set -ex

pip install whitenoise==4.1.3 flower==0.9.3 tornado==5.1.1 backports_abc==0.5

mv /tmp/restore_dump.py /openedx/bin/

mv /tmp/fixtures /openedx/
