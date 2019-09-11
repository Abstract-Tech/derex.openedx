from whitenoise import WhiteNoise

import os


service = os.environ["SERVICE_VARIANT"]
assert service in ("lms", "cms")

application = __import__("{}.wsgi".format(service)).wsgi.application

application = WhiteNoise(application, root="/openedx/staticfiles", prefix="/static")
