#!/bin/sh
set -ex

export STATIC_ROOT_LMS="/openedx/staticfiles"
export STATIC_ROOT_CMS=${STATIC_ROOT_LMS}/studio
export NODE_ENV=production

cd /openedx/edx-platform
export PATH=/openedx/edx-platform/node_modules/.bin:/openedx/bin:${PATH}

python -c "
import sys
sys.argv[1:] = ['common/static/xmodule']
from xmodule import static_content as xmodule_static_content
print('Compiling xmodules')
xmodule_static_content.main()
from pavelib import assets
print('Processing npm assets')
assets.process_npm_assets()
"
webpack --config=webpack.prod.config.js
echo Compiling default themes
python -c "
from pavelib import assets
assets._compile_sass('lms', None, False, False, [])
assets._compile_sass('cms', None, False, False, [])
"

python -c "
from path import Path as path
from pavelib import assets
import os

THEME_DIR = path('/openedx/themes')
for theme in THEME_DIR.listdir():
    if theme.basename().startswith('.'):
        continue
    for system in ('lms', 'cms'):
        if not (THEME_DIR / theme / system).isdir():
            continue
        print('Compiling theme {} ({})'.format(theme.basename(), system))
        assets._compile_sass('lms', theme, False, False, [])
"
echo Collecting assets
SERVICE_VARIANT=lms python manage.py lms --settings=derex.assets collectstatic --link --ignore "fixtures" --ignore "karma_*.js" --ignore "spec" --ignore "spec_helpers" --ignore "spec-helpers" --ignore "xmodule_js" --ignore "geoip" --ignore "sass" --noinput
SERVICE_VARIANT=cms python manage.py cms --settings=derex.assets collectstatic --link --ignore "fixtures" --ignore "karma_*.js" --ignore "spec" --ignore "spec_helpers" --ignore "spec-helpers" --ignore "xmodule_js" --ignore "geoip" --ignore "sass" --noinput
