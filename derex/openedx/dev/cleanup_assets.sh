#!/bin/sh
set -e
set -x

echo Freeing up some space. Before:
du /openedx/staticfiles /openedx/edx-platform/node_modules -sch

# Avoid dulicates: rmlint finds files with the same conents, keeps the oldest
# and symlinks the other copies
rmlint -g -D /openedx/staticfiles /openedx/edx-platform/node_modules
# Do not remove empty files/directories
sed "/# empty /d" -i rmlint.sh
./rmlint.sh -d

echo After:
du /openedx/staticfiles /openedx/edx-platform/node_modules -sch
