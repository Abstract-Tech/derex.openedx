#!/bin/sh
set -e
set -x

export STATIC_ROOT_LMS="/openedx/staticfiles"
export STATIC_ROOT_CMS=${STATIC_ROOT_LMS}/studio
export THEME_DIR="/openedx/themes"
export NODE_ENV=${NODE_ENV:-production}

apk add nodejs
nodeenv /openedx/nodeenv --node=8.9.3 --prebuilt

cd /openedx/edx-platform
/openedx/nodeenv/bin/npm set progress=false
/openedx/nodeenv/bin/npm install
echo PATH=/openedx/edx-platform/node_modules/.bin:/openedx/nodeenv/bin:/openedx/bin:\$\{PATH\}>>~/.profile
PATH=/openedx/edx-platform/node_modules/.bin:/openedx/nodeenv/bin:/openedx/bin:${PATH}

cd /openedx/edx-platform
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
python -c "
from pavelib import assets
assets._compile_sass('lms', None, False, False, [])
assets._compile_sass('cms', None, False, False, [])
"
python -c "
from path import Path as path
from pavelib import assets
import os

THEME_DIR = os.environ.get('THEME_DIR')
for theme in path(THEME_DIR).listdir():
    if theme.basename().startswith('.'):
        continue
    for system in ('lms', 'cms'):
        print('Compiling theme {} ({})'.format(theme.basename(), system))
        assets._compile_sass('lms', theme, False, False, [])
"
echo Collecting assets
python manage.py lms --settings=derex.assets collectstatic --ignore "fixtures" --ignore "karma_*.js" --ignore "spec" --ignore "spec_helpers" --ignore "spec-helpers" --ignore "xmodule_js" --ignore "geoip" --ignore "sass" --noinput
python manage.py cms --settings=derex.assets collectstatic --ignore "fixtures" --ignore "karma_*.js" --ignore "spec" --ignore "spec_helpers" --ignore "spec-helpers" --ignore "xmodule_js" --ignore "geoip" --ignore "sass" --noinput
