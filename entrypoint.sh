#!/bin/sh
# Entrypoint script to make sure that container writes files as 
# the calling user of docker container.

USER_ID=${LOCAL_USER_ID:-9001}
USER_NAME=$( getent passwd $USER_ID |cut -d: -f1 )
getent passwd $USER_ID
if [ -z $USER_NAME ]; then
    echo "User id $USER_ID does not exist."
    adduser -s /bin/sh -u $USER_ID user -D
    USER_NAME="user"
fi
echo "Starting with user: $USER_ID ($USER_NAME)"
export HOME=/home/$USER_NAME

mkdir -p /home/$USER_NAME/jekyll
mkdir -p /home/$USER_NAME/jekyll/_site
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/jekyll
cd /home/$USER_NAME/jekyll
exec su-exec $USER_NAME jekyll "$@"
