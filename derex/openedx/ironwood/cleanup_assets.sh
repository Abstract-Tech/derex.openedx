#!/bin/sh
set -e
set -x

echo Freeing up some space. Before:
du / -sch

apk del nodejs rsync make g++ npm --no-cache

# Saving come directories symlinked from /openedx/edx-platform/common/static/
to_save='@edx edx-pattern-library edx-ui-toolkit'
for saveme in $to_save; do
    mv /openedx/edx-platform/node_modules/"${saveme}" /
done
touch /tmp/make_sure_the_star_below_matches_something
rm -r \
    /openedx/edx-platform/node_modules/ `# 368.9M` \
    /openedx/staticfiles/studio-frontend/node_modules `# 24.3M` \
    /openedx/staticfiles/cookie-policy-banner/node_modules `# 5.7M` \
    /openedx/staticfiles/edx-bootstrap/node_modules `# 10.9M` \
    /openedx/staticfiles/paragon/node_modules `# 13.3M` \
    /tmp/*

if ! mount | grep /root/.npm; then
    rm -rf /root/.npm/* # 52.5M
fi

mkdir /openedx/edx-platform/node_modules
for saveme in $to_save; do
    mv /"${saveme}" /openedx/edx-platform/node_modules
done


echo After:
du / -sch
