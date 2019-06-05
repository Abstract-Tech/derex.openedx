#!/bin/sh

# Symlink musl so that `ctypes.util:find_library` can find a pointer
# to the `free` function when shapely.geos reaches the line
# free = load_dll('c').free

ln -s /lib/libc.musl-x86_64.so.1 /lib/c
