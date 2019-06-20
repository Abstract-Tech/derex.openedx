#!/bin/sh
set -e
set -x

echo Freeing up some space. Before:
du / -sch
rm -r \
    /openedx/nodeenv/ `# 137.3M` \
    /openedx/edx-platform/node_modules/ `# 368.9M` \
    /usr/lib/node_modules/ `# 30.4M` \
    /openedx/staticfiles/studio-frontend/node_modules `# 24.3M` \
    /openedx/staticfiles/cookie-policy-banner/node_modules `# 5.7M` \
    /openedx/staticfiles/edx-bootstrap/node_modules `# 10.9M` \
    /openedx/staticfiles/paragon/node_modules `# 13.3M`
apk del nodejs # 52M

echo After:
du / -sch
