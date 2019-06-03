#!/bin/sh
set -xe
# Patch  mariadb's mysql.h to work with python mysql connector
# Thanks to morissette and Warfront1 from this thread:
# https://github.com/DefectDojo/django-DefectDojo/issues/407
sed -i.bak -e '/st_mysql_options options;/a unsigned int reconnect;' /usr/include/mysql/mysql.h
