import os

from openedx.core.lib.derived import derive_settings
from path import Path as path
from xmodule.modulestore.modulestore_settings import \
    update_module_store_settings

SERVICE_VARIANT = os.environ["SERVICE_VARIANT"]
assert SERVICE_VARIANT in ("lms", "cms")

exec("from {}.envs.common import *".format(SERVICE_VARIANT), globals(), locals())

DATABASES = {
    "default": {
        "ATOMIC_REQUESTS": True,
        "ENGINE": "django.db.backends.mysql",
        "HOST": "mysql",
        "NAME": "derex",
        "PASSWORD": "",
        "PORT": "3306",
        "USER": "root",
    }
}

CONTENTSTORE = {
    "ENGINE": "xmodule.contentstore.mongo.MongoContentStore",
    "DOC_STORE_CONFIG": {"host": "mongodb", "db": "mongoedx"},
}
DOC_STORE_CONFIG = {"host": "mongodb", "db": "mongoedx"}
update_module_store_settings(MODULESTORE, doc_store_settings=DOC_STORE_CONFIG)

XQUEUE_INTERFACE = {"url": None, "django_auth": None}
ALLOWED_HOSTS = ["*"]

##################### CMS Settings ###################

if SERVICE_VARIANT == "cms":
    CMS_SEGMENT_KEY = "foobar"
    LOGIN_URL = "/signin"
    FRONTEND_LOGIN_URL = LOGIN_URL

derive_settings(__name__)
