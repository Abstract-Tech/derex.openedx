#!/bin/sh
set -e
set -x

echo Freeing up some space. Before:
du /openedx -sch

# Avoid dulicates: rmlint finds files with the same conents, keeps the oldest
# and symlinks the other copies
rmlint -o sh:rmlint.sh -c sh:symlink -g /openedx/
# Do not remove empty files/directories
sed "/# empty /d" -i rmlint.sh
./rmlint.sh -d

echo After:
du /openedx -sch
