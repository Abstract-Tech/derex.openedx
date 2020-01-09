#!/bin/sh
set -e

if [ -z "$TRANSIFEX_USERNAME" ] || [ -z "$TRANSIFEX_PASSWORD" ]; then
    echo "Transifex credentials unset. Building without translations."
    exit 0
fi

printf '[https://www.transifex.com]\nhostname=https://www.transifex.com\nusername=%s\npassword=%s\n' "$TRANSIFEX_USERNAME" "$TRANSIFEX_PASSWORD" > ~/.transifexrc

set -x

cd /openedx/edx-platform

pip install transifex-client

i18n_tool transifex pull
i18n_tool extract

i18n_tool generate

python manage.py lms --settings=derex.assets compilemessages -v2
python manage.py cms --settings=derex.assets compilemessages -v2

python manage.py lms --settings=derex.assets compilejsi18n -v2
python manage.py cms --settings=derex.assets compilejsi18n -v2

i18n_tool validate || (find conf|grep prob; find conf|grep prob|xargs cat; false)

rm ~/.transifexrc
