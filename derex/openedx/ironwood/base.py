from openedx.core.lib.derived import derive_settings
from path import Path as path
from xmodule.modulestore.modulestore_settings import update_module_store_settings

import os


SERVICE_VARIANT = os.environ["SERVICE_VARIANT"]
assert SERVICE_VARIANT in ("lms", "cms")

exec("from {}.envs.common import *".format(SERVICE_VARIANT), globals(), locals())

PLATFORM_NAME = "TestEdX"
MYSQL_HOST = os.environ.get("MYSQL_HOST", "mysql")
MYSQL_PORT = os.environ.get("MYSQL_PORT", "3306")
MYSQL_DB = os.environ.get("MYSQL_DB", "derex")
MYSQL_USER = os.environ.get("MYSQL_USER", "root")
MYSQL_PASSWORD = os.environ.get("MYSQL_PASSWORD", "secret")
DATABASES = {
    "default": {
        "ATOMIC_REQUESTS": True,
        "ENGINE": "django.db.backends.mysql",
        "HOST": MYSQL_HOST,
        "NAME": MYSQL_DB,
        "PASSWORD": MYSQL_PASSWORD,
        "PORT": MYSQL_PORT,
        "USER": MYSQL_USER,
    }
}
MONGODB_HOST = "mongodb"
MONGODB_DB = "mongoedx"
CONTENTSTORE = {
    "ENGINE": "xmodule.contentstore.mongo.MongoContentStore",
    "DOC_STORE_CONFIG": {"host": MONGODB_HOST, "db": MONGODB_DB},
}
DOC_STORE_CONFIG = {"host": MONGODB_HOST, "db": MONGODB_DB}
update_module_store_settings(MODULESTORE, doc_store_settings=DOC_STORE_CONFIG)

XQUEUE_INTERFACE = {"url": None, "django_auth": None}
ALLOWED_HOSTS = ["*"]

if "runserver" in sys.argv:
    DEBUG = True
    PIPELINE_ENABLED = False
    STATICFILES_STORAGE = "openedx.core.storage.DevelopmentStorage"
    # Revert to the default set of finders as we don't want the production pipeline
    STATICFILES_FINDERS = [
        "openedx.core.djangoapps.theming.finders.ThemeFilesFinder",
        "django.contrib.staticfiles.finders.FileSystemFinder",
        "django.contrib.staticfiles.finders.AppDirectoriesFinder",
    ]
    # Disable JavaScript compression in development
    PIPELINE_JS_COMPRESSOR = None
    # Whether to run django-require in debug mode.
    REQUIRE_DEBUG = DEBUG
    PIPELINE_SASS_ARGUMENTS = "--debug-info"
    # Load development webpack donfiguration
    WEBPACK_CONFIG_PATH = "webpack.dev.config.js"

EMAIL_HOST = os.environ.get("EMAIL_HOST", "smtp")
EMAIL_PORT = os.environ.get("EMAIL_PORT", "25")
EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"

##################### Celery #######################
CELERY_BROKER_TRANSPORT = os.environ.get("CELERY_BROKER_TRANSPORT", "amqp")
CELERY_BROKER_HOSTNAME = os.environ.get("CELERY_BROKER_HOSTNAME", "rabbitmq")
CELERY_BROKER_USER = os.environ.get("CELERY_BROKER_USER", "guest")
CELERY_BROKER_PASSWORD = os.environ.get("CELERY_BROKER_PASSWORD", "guest")
CELERY_BROKER_VHOST = os.environ.get("CELERY_BROKER_VHOST", "/")
BROKER_URL = "{0}://{1}:{2}@{3}/{4}".format(
    CELERY_BROKER_TRANSPORT,
    CELERY_BROKER_USER,
    CELERY_BROKER_PASSWORD,
    CELERY_BROKER_HOSTNAME,
    CELERY_BROKER_VHOST,
)
CELERY_RESULT_BACKEND = "db+mysql://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}/{MYSQL_DB}".format(
    **locals()
)
CELERY_RESULT_BACKEND = "mongodb://{MONGODB_HOST}/".format(**locals())
CELERY_MONGODB_BACKEND_SETTINGS = {
    "database": MONGODB_DB,
    "taskmeta_collection": "taskmeta_collection",
}

CELERY_RESULT_DB_TABLENAMES = {"task": "celery_edx_task", "group": "celery_edx_group"}
##################### CMS Settings ###################

LMS_BASE = "http://localhost:4700"

if SERVICE_VARIANT == "cms":
    CMS_SEGMENT_KEY = "foobar"
    LOGIN_URL = "/signin"
    FRONTEND_LOGIN_URL = LOGIN_URL

derive_settings(__name__)
