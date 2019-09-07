#!/usr/bin/env python
"""Reduce disk usage by symlinking byte-to-byte equal files with similar names.
Webpack leaves a lot of these behind. There's no reason to have the same file
sitting on the disk multiple times.
"""
from path import Path as path

import sys


def prune_dir(directory):
    files = sorted((el for el in directory.listdir() if el.isfile()), reverse=True)
    basenames = {el.basename().split(".")[0] for el in files}
    for basename in basenames:
        candidates = [el for el in files if el.basename().startswith(basename)]
        canonical = candidates[0]
        for replacement in candidates[1:]:
            if replacement.islink():
                continue
            if replacement.bytes() == canonical.bytes():
                replacement.remove()
                canonical.basename().symlink(replacement)
    for el in directory.listdir():
        if el.isdir():
            prune_dir(el)


def main():
    for directory in sys.argv[1:]:
        prune_dir(path(directory))


if __name__ == "__main__":
    main()
