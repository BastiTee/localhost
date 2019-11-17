#!/bin/sh
# Entrypoint script to make sure that container writes files as 
# the calling user of docker container.

USER_ID=${LOCAL_USER_ID:-9001}

echo "Starting with UID : $USER_ID"
adduser -s /bin/sh -u $USER_ID user -D 
export HOME=/home/user

mkdir -p /home/user/jekyll
mkdir -p /home/user/jekyll/_cache
mkdir -p /home/user/jekyll/_site
chown -R user:user /home/user/jekyll
cd /home/user/jekyll
exec su-exec user jekyll "$@"
