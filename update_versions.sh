#!/bin/sh

wget https://raw.githubusercontent.com/edx/edx-platform/open-release/juniper.alpha1/requirements/edx/base.txt -O derex/openedx/nostatic/requirements_all.txt
sed -e s@file:///openedx/edx-platform/@@ -i derex/openedx/nostatic/requirements_all.txt
sed -e s@file:///openedx/edx-platform@.@ -i derex/openedx/nostatic/requirements_all.txt
sed 's/^-e git/git/' -i derex/openedx/nostatic/requirements_all.txt
echo "--find-links http://pypi.abzt.de/alpine-3.11" >> derex/openedx/nostatic/requirements_all.txt
echo "--trusted-host pypi.abzt.de" >> derex/openedx/nostatic/requirements_all.txt
grep -E -v '^-e|^git.https://' derex/openedx/nostatic/requirements_all.txt > derex/openedx/wheels/requirements.txt
grep -E '^-e|^git.https://' derex/openedx/nostatic/requirements_all.txt > derex/openedx/nostatic/requirements.txt
