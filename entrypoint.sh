#!/bin/sh
# Entrypoint script to make sure that container writes files as 
# the calling user of docker container.

USER_ID=${LOCAL_USER_ID:-9001}
getent passwd $USER_ID
adduser -s /bin/sh -u $USER_ID user -D ||true
echo "Starting with user: $USER_ID"
echo "Executing jekyll $@"

mkdir -p /usr/share/jekyll
mkdir -p /usr/share/jekyll/_site
chown -R $USER_ID:$USER_ID /usr/share/jekyll
cd /usr/share/jekyll
exec su-exec $USER_ID jekyll "$@"
