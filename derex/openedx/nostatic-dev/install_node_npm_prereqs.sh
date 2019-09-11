#!/bin/sh
set -ex

apk add npm nodejs g++ make
cd /openedx/edx-platform
npm install
