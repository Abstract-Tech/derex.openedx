#!/bin/sh
export DJANGO_SETTINGS_MODULE=$SERVICE_VARIANT.envs.$SETTINGS
exec "$@"