#!/bin/sh
set -e
cd "$( cd "$( dirname "$0" )"; pwd )"

DEFAULT_COMMAND="server \
--drafts \
--host 0.0.0.0 \
--port 50600 \
--incremental \
--livereload \
--watch \
--livereload-port 50601 \
--trace \
"

print_help() {
    cat << EOF
Usage: $( basename $0 ) [OPTS]

Options:
    -p  DIR     Jekyll _posts folder (default: ./example-notebook/posts)
    -d  DIR     Jekyll _drafts folder (default: ./example-notebook/drafts)
    -a  DIR     Assets folder (default: ./example-notebook/assets)
    -t  DIR     Jekyll _site folder (default: ./_site)
    -c  CMD     Jekyll command line (default: $DEFAULT_COMMAND)
    -g          Only generate target site
    -s          Skip docker image creation
EOF
exit 0
}

while getopts p:d:a:t:c:gsh opt
do
   case $opt in
       p) POSTS_FOLDER=$OPTARG;;
       d) DRAFTS_FOLDER=$OPTARG;;
       a) ASSETS_FOLDER=$OPTARG;;
       t) TARGET_FOLDER=$OPTARG;;
       c) COMMAND="$OPTARG";;
       g) GENERATE=1;;
       s) SKIP_DOCKER=1;;
       h) print_help ;;
       *) print_help ;;
   esac
done
POSTS_FOLDER=${POSTS_FOLDER:-$(pwd)/example-notebook/posts}
DRAFTS_FOLDER=${DRAFTS_FOLDER:-$(pwd)/example-notebook/drafts}
ASSETS_FOLDER=${ASSETS_FOLDER:-$(pwd)/example-notebook/assets}
TARGET_FOLDER=${TARGET_FOLDER:-$(pwd)/_site}
COMMAND=${COMMAND:-$DEFAULT_COMMAND}
GENERATE=${GENERATE:-0}
SKIP_DOCKER=${SKIP_DOCKER:-0}
[ $GENERATE -eq 1 ] && COMMAND="build"
cat << EOF
---
POSTS FOLDER:   $POSTS_FOLDER
DRAFTS FOLDER:  $DRAFTS_FOLDER
ASSETS FOLDER:  $ASSETS_FOLDER
TARGET FOLDER:  $TARGET_FOLDER
JEKYLL COMMAND: $COMMAND
---
EOF

# Create jekyll docker image
[ $SKIP_DOCKER -eq 0 ] && docker build -t "basti-tee/jekyll" .

# Run dockerized jekyll
docker run --rm -ti -p 50600:50600 -p 50601:50601 \
-e LOCAL_USER_ID=`id -u $USER` \
-v $(pwd)/_config.yml:/home/user/jekyll/_config.yml \
-v $(pwd)/index.md:/home/user/jekyll/index.md \
-v $(pwd)/feed.xml:/home/user/jekyll/feed.xml \
-v $(pwd)/_includes:/home/user/jekyll/_includes \
-v $(pwd)/_layouts:/home/user/jekyll/_layouts \
-v $(pwd)/_plugins:/home/user/jekyll/_plugins \
-v $(pwd)/res:/home/user/jekyll/res \
-v ${POSTS_FOLDER}:/home/user/jekyll/_posts \
-v ${DRAFTS_FOLDER}:/home/user/jekyll/_drafts \
-v ${ASSETS_FOLDER}:/home/user/jekyll/res/assets \
-v ${TARGET_FOLDER}:/home/user/jekyll/_site \
"basti-tee/jekyll" \
$COMMAND
