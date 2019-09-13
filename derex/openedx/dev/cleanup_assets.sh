#!/bin/sh
set -e
set -x

echo Freeing up some space. Before:
du /openedx -sch

if ! mount | grep /root/.npm; then
    rm -rf /root/.npm/* # 52.5M
fi

# Avoid dulicates: rmlint finds files with the same conents, keeps the oldest
# and symlinks the other copies
rmlint -g -D /openedx
# Do not remove empty files/directories
sed "/# empty /d" -i rmlint.sh
./rmlint.sh -d > /dev/null

echo After:
du /openedx -sch
