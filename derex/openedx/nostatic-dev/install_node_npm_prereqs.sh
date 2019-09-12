#!/bin/sh
set -ex

# rmlint's shell script uses features of mktemp not present in busybox
# hence we install coreutils
apk add npm nodejs g++ make coreutils
cd /openedx/edx-platform
npm install
