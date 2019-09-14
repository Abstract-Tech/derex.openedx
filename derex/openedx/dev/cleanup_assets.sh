#!/bin/sh
set -e
set -x

# Avoid dulicates: rmlint finds files with the same conents, keeps the oldest
# and symlinks the other copies
rmlint -o sh:rmlint.sh -c sh:symlink -o json:stderr -g \
    /openedx/staticfiles \
    /openedx/edx-platform/common/static/ \
    /openedx/edx-platform/lms/static/ \
    /openedx/edx-platform/cms/static/ \
    2>/dev/null
# Do not remove empty files/directories
sed "/# empty /d" -i rmlint.sh
./rmlint.sh -d
