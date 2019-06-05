#!/bin/sh
set -e
set -x

apk add nodejs-npm alpine-sdk

cd /openedx/edx-platform
npm install -g npm
npm set progress=false
npm install
echo PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:\$\{PATH\}>>~/.profile
PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:${PATH}

cd /openedx/edx-platform
openedx-assets xmodule
openedx-assets npm
openedx-assets webpack --env=prod
openedx-assets common

openedx-assets themes
openedx-assets collect --settings=derex.assets

# Free up some space
echo Freeing up some space. Before:
du / -sch
rm -r \
    /openedx/edx-platform/node_modules/ `# 368.9M` \
    /usr/lib/node_modules/ `# 30.4M` \
    /openedx/staticfiles/studio-frontend/node_modules `# 24.3M` \
    /openedx/staticfiles/cookie-policy-banner/node_modules `# 5.7M` \
    /openedx/staticfiles/edx-bootstrap/node_modules `# 10.9M` \
    /openedx/staticfiles/paragon/node_modules `# 13.3M`
apk del nodejs-npm alpine-sdk # 100M

echo After:
du / -sch
