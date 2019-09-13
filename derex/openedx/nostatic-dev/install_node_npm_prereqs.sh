#!/bin/sh
set -ex

# rmlint's shell script uses features of mktemp not present in busybox
# hence we install coreutils
apk add npm nodejs g++ make coreutils
cd /openedx/edx-platform
npm install

# Avoid dulicates: rmlint finds files with the same conents, keeps the oldest
# and symlinks the other copies
rmlint -o sh:rmlint.sh -c sh:symlink -g node_modules
# Do not remove empty files/directories
sed "/# empty /d" -i rmlint.sh
./rmlint.sh -d
