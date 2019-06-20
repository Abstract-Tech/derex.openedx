#!/usr/bin/env python
import bz2

import MySQLdb
from django.conf import settings

DUMP_FILE_PATH = "/openedx/empty_dump.sql.bz2"


def get_dump_file_contents():
    return bz2.BZ2File(DUMP_FILE_PATH).read()


def get_connection(include_db=True):
    kwargs = dict(
        host=settings.DATABASES["default"]["HOST"],
        port=int(settings.DATABASES["default"].get("PORT", 3306)),
        user=settings.DATABASES["default"]["USER"],
        passwd=settings.DATABASES["default"]["PASSWORD"],
    )
    if include_db:
        kwargs["db"] = settings.DATABASES["default"]["NAME"]
    return MySQLdb.connect(**kwargs)


def main():
    admin_cursor = get_connection(include_db=False).cursor()
    admin_cursor.execute(
        "DROP DATABASE IF EXISTS {}".format(settings.DATABASES["default"]["NAME"])
    )
    admin_cursor.execute(
        "CREATE DATABASE {}".format(settings.DATABASES["default"]["NAME"])
    )
    sql = get_dump_file_contents()
    cursor = get_connection().cursor()
    cursor.execute(sql)


if __name__ == "__main__":
    main()
