#!/bin/sh
set -e
cd "$( cd "$( dirname "$0" )"; pwd )"

DEFAULT_COMMAND="server \
--host 0.0.0.0 \
--port 8000 \
--trace \
--incremental \
--drafts \
--livereload \
--watch \
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
EOF
exit 0
}

while getopts p:d:a:t:c:nh opt
do
   case $opt in
       p) POSTS_FOLDER=$OPTARG;;
       d) DRAFTS_FOLDER=$OPTARG;;
       a) ASSETS_FOLDER=$OPTARG;;
       t) TARGET_FOLDER=$OPTARG;;
       c) COMMAND="$OPTARG";;
       h) print_help ;;
       *) print_help ;;
   esac
done
POSTS_FOLDER=${POSTS_FOLDER:-$(pwd)/example-notebook/posts}
DRAFTS_FOLDER=${DRAFTS_FOLDER:-$(pwd)/example-notebook/drafts}
ASSETS_FOLDER=${ASSETS_FOLDER:-$(pwd)/example-notebook/assets}
TARGET_FOLDER=${TARGET_FOLDER:-$(pwd)/_site}
COMMAND=${COMMAND:-$DEFAULT_COMMAND}
if [ $NATIVE -eq 1 ]; then
    COMMAND=$( echo $COMMAND | sed -e "s/0.0.0.0/localhost/" )
fi
cat << EOF
---
POSTS FOLDER:   $POSTS_FOLDER
DRAFTS FOLDER:  $DRAFTS_FOLDER
ASSETS FOLDER:  $ASSETS_FOLDER
TARGET FOLDER:  $TARGET_FOLDER
JEKYLL COMMAND: $COMMAND
NATIVE:         $NATIVE
---
EOF

# Create jekyll docker image
docker build -t "basti-tee/jekyll" .

# Run dockerized jekyll
docker run --rm -ti -p 8000:8000 \
-v $(pwd)/_config.yml:/jekyll/_config.yml \
-v $(pwd)/index.md:/jekyll/index.md \
-v $(pwd)/feed.xml:/jekyll/feed.xml \
-v $(pwd)/_includes:/jekyll/_includes \
-v $(pwd)/_layouts:/jekyll/_layouts \
-v $(pwd)/_plugins:/jekyll/_plugins \
-v $(pwd)/res:/jekyll/res \
-v ${POSTS_FOLDER}:/jekyll/_posts \
-v ${DRAFTS_FOLDER}:/jekyll/_drafts \
-v ${ASSETS_FOLDER}:/jekyll/res/assets \
-v ${TARGET_FOLDER}:/jekyll/_site \
"basti-tee/jekyll" \
$COMMAND
