"""
Bare minimum settings for dumping database migrations.
"""

from ..common import *  # type: ignore
from openedx.core.lib.derived import derive_settings


DATABASES = {"default": {"ENGINE": "django.db.backends.mysql", "NAME": "edxapp"}}

# We need to define this, or we get an error
XQUEUE_INTERFACE = {"django_auth": None, "url": None}

derive_settings(__name__)
