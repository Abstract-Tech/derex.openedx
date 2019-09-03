"""
Bare minimum settings for collecting production assets.
"""

from ..common import *  # type: ignore
from openedx.core.lib.derived import derive_settings
from path import Path as path

import os


COMPREHENSIVE_THEME_DIRS.append("/openedx/themes")  # type: ignore
STATIC_ROOT_BASE = "/openedx/staticfiles"
STATIC_ROOT = {  # type: ignore
    "lms": path(STATIC_ROOT_BASE),
    "cms": path(STATIC_ROOT_BASE) / "studio",
}[os.environ.get("SERVICE_VARIANT")]
WEBPACK_LOADER["DEFAULT"]["STATS_FILE"] = (  # type: ignore
    STATIC_ROOT / "webpack-stats.json"
)

SECRET_KEY = "secret"
XQUEUE_INTERFACE = {"django_auth": None, "url": None}
DATABASES = {"default": {}}  # type: ignore

# Prevent KeyError: u'cornerstone' error in simple_history/models:212
# https://github.com/treyhunner/django-simple-history/blob/b1d9adbd838836246b052b4c9c4598e02f6471c5/simple_history/models.py#L213
INSTALLED_APPS.append("integrated_channels.cornerstone")

derive_settings(__name__)
