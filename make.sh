#!/bin/sh
set -e
cd "$( cd "$( dirname "$0" )"; pwd )"

SERVER_CMD="server \
--drafts \
--host 0.0.0.0 \
--port 50600 \
--incremental \
--livereload \
--watch \
--livereload-port 50601 \
--trace \
"

BUILD_CMD="build \
--trace \
"

print_help() {
    cat << EOF
Usage: $( basename $0 ) [OPTS]

Options:
    -y  YAML  Input configuration file (default: ./_config.yml)
    -p  DIR   Jekyll _posts folder (default: ./example-notebook/posts)
    -d  DIR   Jekyll _drafts folder (default: ./example-notebook/drafts)
    -a  DIR   Assets folder (default: ./example-notebook/assets)
    -t  DIR   Jekyll _site folder (default: ./_site)
    -c  DIR   Jekyll preview cache (default: ./_cache)
    -x  CMD   Jekyll command line (default: $SERVER_CMD)
    -g        Only generate target site
    -s        Skip docker image creation
EOF
exit 0
}

while getopts y:p:d:a:t:x:c:gsh opt
do
   case $opt in
       y) YAML_FILE=$OPTARG;;
       p) POSTS_FOLDER=$OPTARG;;
       d) DRAFTS_FOLDER=$OPTARG;;
       a) ASSETS_FOLDER=$OPTARG;;
       t) TARGET_FOLDER=$OPTARG;;
       c) CACHE_FOLDER=$OPTARG;;
       x) COMMAND="$OPTARG";;
       g) GENERATE=1;;
       s) SKIP_DOCKER=1;;
       h) print_help ;;
       *) print_help ;;
   esac
done
YAML_FILE=${YAML_FILE:-$(pwd)/_config.yml}
POSTS_FOLDER=${POSTS_FOLDER:-$(pwd)/example-notebook/posts}
DRAFTS_FOLDER=${DRAFTS_FOLDER:-$(pwd)/example-notebook/drafts}
ASSETS_FOLDER=${ASSETS_FOLDER:-$(pwd)/example-notebook/assets}
CACHE_FOLDER=${CACHE_FOLDER:-$(pwd)/_cache}
mkdir -p $CACHE_FOLDER
TARGET_FOLDER=${TARGET_FOLDER:-$(pwd)/_site}
COMMAND=${COMMAND:-$SERVER_CMD}
[ ${GENERATE:-0} -eq 1 ] && COMMAND="$BUILD_CMD"
SKIP_DOCKER=${SKIP_DOCKER:-0}
cat << EOF
---
YAML FILE:      $YAML_FILE
POSTS FOLDER:   $POSTS_FOLDER
DRAFTS FOLDER:  $DRAFTS_FOLDER
ASSETS FOLDER:  $ASSETS_FOLDER
CACHE FOLDER:   $CACHE_FOLDER
TARGET FOLDER:  $TARGET_FOLDER
JEKYLL COMMAND: $COMMAND
---
EOF

# Create jekyll docker image
[ $SKIP_DOCKER -eq 0 ] && docker build -t "basti-tee/jekyll" .

# Run dockerized jekyll
docker run --rm -p 50600:50600 -p 50601:50601 \
-e LOCAL_USER_ID=`id -u $USER` \
-v ${YAML_FILE}:/usr/share/jekyll/_config.yml \
-v $(pwd)/index.md:/usr/share/jekyll/index.md \
-v $(pwd)/feed.xml:/usr/share/jekyll/feed.xml \
-v $(pwd)/_includes:/usr/share/jekyll/_includes \
-v $(pwd)/_layouts:/usr/share/jekyll/_layouts \
-v $(pwd)/_plugins:/usr/share/jekyll/_plugins \
-v $(pwd)/res:/usr/share/jekyll/res \
-v ${POSTS_FOLDER}:/usr/share/jekyll/_posts \
-v ${DRAFTS_FOLDER}:/usr/share/jekyll/_drafts \
-v ${ASSETS_FOLDER}:/usr/share/jekyll/res/assets \
-v ${CACHE_FOLDER}:/usr/share/jekyll/_cache \
-v ${TARGET_FOLDER}:/usr/share/jekyll/_site \
"basti-tee/jekyll" \
$COMMAND
