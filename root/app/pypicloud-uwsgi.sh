#!/bin/bash

if [ -z "$UWSGI_USER" ] || [ "$UWSGI_USER" = "root" ]; then
  uwsgi --die-on-term /config/config.ini
else
  /usr/sbin/setuser "$UWSGI_USER" uwsgi --die-on-term /config/config.ini
fi
