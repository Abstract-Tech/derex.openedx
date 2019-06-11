#!/bin/sh
set -e

if [[ -z $TRANSIFEX_USERNAME || -z $TRANSIFEX_PASSWORD ]]; then
        echo "Transifex credentials unset. Building without translations."
        exit 0
fi

echo -e "[https://www.transifex.com]\nhostname=https://www.transifex.com\nusername=$TRANSIFEX_USERNAME\npassword=$TRANSIFEX_PASSWORD" |tee ~/.transifexrc

set -x

cd /openedx/edx-platform

pip install transifex-client

# Comment out broken languages (Chinese and Russian as of 11-06-2019)
for lang in "zh" "ru"
do
        sed -i -e "s/    - $lang/    # - $lang/" "conf/locale/config.yaml"
done

i18n_tool transifex pull
i18n_tool extract

# Fix broken plural expression header
for file in "django-partial.po" "django-studio.po" "djangojs-partial.po" "djangojs-studio.po"
do
        sed -i -e "s/nplurals=INTEGER/nplurals=2/" "conf/locale/en/LC_MESSAGES/$file"
        sed -i -e "s/plural=EXPRESSION/plural=\(n != 1\)/" "conf/locale/en/LC_MESSAGES/$file"
done

i18n_tool generate

python manage.py lms --settings=derex.assets compilemessages -v2
python manage.py cms --settings=derex.assets compilemessages -v2

python manage.py lms --settings=derex.assets compilejsi18n -v2
python manage.py cms --settings=derex.assets compilejsi18n -v2

i18n_tool validate

rm ~/.transifexrc
