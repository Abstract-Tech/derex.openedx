"""Unified cms/lms celery configuration.
edX provides celery config that separates cms and lms workers.
This file makes it possible to run a single worker to serve
all edX needs.
"""
from celery import Celery
from django.conf import settings


INSTALLED_APPS = settings.INSTALLED_APPS
# Only after we materialize `settings` can we import these
from cms.envs.common import INSTALLED_APPS as CMS_INSTALLED_APPS
from lms.envs.common import INSTALLED_APPS as LMS_INSTALLED_APPS


# Add all settings in common regarding cms
import cms.envs.common

for attr in dir(cms.envs.common):
    if not hasattr(settings, attr):
        setattr(settings, attr, getattr(cms.envs.common, attr))

# These guys break celery. Only entitlements defines tasks.
BLACKLIST = ["completion", "microsite_configuration", "entitlements"]
INSTALLED_APPS += [el for el in LMS_INSTALLED_APPS if el not in INSTALLED_APPS]
INSTALLED_APPS += [
    el for el in CMS_INSTALLED_APPS if el not in INSTALLED_APPS and el not in BLACKLIST
]
if "common.djangoapps.entitlements.tasks" not in settings.CELERY_IMPORTS:
    settings.CELERY_IMPORTS.append("common.djangoapps.entitlements.tasks")


# Put our updated list of installed apps back in place:
# django_setup() is called in the celery startup
# Note that this is not necessary because we modified the original list already.
# But we want to signal to the reader that this is the case.
settings.INSTALLED_APPS = INSTALLED_APPS

APP = Celery("edx")
# Using a string here means the worker will not have to
# pickle the object when using Windows.
APP.config_from_object("django.conf:settings")
APP.autodiscover_tasks(lambda: INSTALLED_APPS)
