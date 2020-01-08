Alpine docker image
===================

This directory contains scripts to build an openedx image based
on Alpine Linux. The goal is to have a small image and fast image build.

`derex.builder` is used to build the images. In turn, it uses buildah.
This setup is more complex than a classic Dockerfile, but allows more flexibility
resulting in faster image build.

In particular `derex.builder` can use (if instructed via the env vars `PIP_CACHE`,
`APK_CACHE` and `NPM_CACHE`) caches persistent across builds to avoid recompiling the
same python wheel over and over again.

Images used in intermediate steps
---------------------------------

To achieve the goal of fast image build, image preparation is divided into multiple steps.

The idea behind this is that some parts change more often than others, and we can build base images with the ones that are seldom updated, like operating system dependencies; the same reasoning is done about python wheels and the edx-platform code itself.

Two images are created using the python alpine one as a base.
One includes all packages needed to build wheels, the other one with packages needed at runtime.

The wheels builder is used to build the wheels, and they are pip installed into the runtime image.

At this point the runtime image is able to run code provided by an `edx-platform` checkout and config files.

The last image bundles edx-platform.

These are the image names:

* `openedx-<VERSION>-buildwheels`: build dependencies included
* `openedx-<VERSION>-base`: just runtime dependencies
* `openedx-<VERSION>-wheels`: wheels preinstalled for a specific edx-platform version, but no python code from edx-platform
* `openedx-<VERSION>-nostatic`: everything to run openedx, except javascript/css tools and staticfiles
* `openedx-<VERSION>-nostatic-dev`: like nostatic, but includes also all dev tools to generate static files
* `openedx-<VERSION>-dev`: all edx code and static assets, with javascript dev tools installed
* `openedx-<VERSION>`: all edx code and static assets, with no dev tools


### Build with translations

In order to build with translations from Transifex the `TRANSIFEX_USERNAME` and `TRANSIFEX_PASSWORD` environment variables must be set in the shell environment running the build.
