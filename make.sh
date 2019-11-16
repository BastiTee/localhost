#!/bin/sh
set -e
cd "$( cd "$( dirname "$0" )"; pwd )"

# Command line parsing
POSTS_FOLDER=${1:-$(pwd)/_posts}
TARGET_FOLDER=${2:-$(pwd)/_site}
COMMAND=${3:-server --host 0.0.0.0 --port 8000 --incremental}
echo "POSTS FOLDER:   $POSTS_FOLDER"
echo "TARGET FOLDER:  $TARGET_FOLDER"
echo "JEKYLL COMMAND: $COMMAND"

# Create jekyll docker image
docker build -t "basti-tee/jekyll" .

# Prepare input/output folders
mkdir -p $TARGET_FOLDER
mkdir -p $POSTS_FOLDER/res/assets

# Run dockerized jekyll
docker run --rm -ti -p 8000:8000 \
-v $(pwd)/_includes:/jekyll/_includes \
-v $(pwd)/_layouts:/jekyll/_layouts \
-v $(pwd)/_plugins:/jekyll/_plugins \
-v $(pwd)/res:/jekyll/res \
-v ${POSTS_FOLDER}:/jekyll/_posts \
-v ${POSTS_FOLDER}/res/assets:/jekyll/res/assets \
-v ${TARGET_FOLDER}:/jekyll/_site \
"basti-tee/jekyll" \
$COMMAND
