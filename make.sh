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
    -p  DIR     Jekyll _posts folder (default: ./example_notebook/posts)
    -d  DIR     Jekyll _drafts folder (default: ./example_notebook/drafts)
    -a  DIR     Assets folder (default: ./example_notebook/assets)
    -t  DIR     Jekyll _site folder (default: ./_site)
    -c  CMD     Jekyll command line (default: $DEFAULT_COMMAND)
    -n          Run native instead inside docker
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
       n) NATIVE=1;;
       h) print_help ;;
       *) print_help ;;
   esac
done
POSTS_FOLDER=${POSTS_FOLDER:-$(pwd)/example_notebook/posts}
DRAFTS_FOLDER=${DRAFTS_FOLDER:-$(pwd)/example_notebook/drafts}
ASSETS_FOLDER=${ASSETS_FOLDER:-$(pwd)/example_notebook/assets}
TARGET_FOLDER=${TARGET_FOLDER:-$(pwd)/_site}
NATIVE=${NATIVE:-0}
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

if [ $NATIVE -eq 0 ]; then 
    # mkdir -p $TARGET_FOLDER
    # mkdir -p $POSTS_FOLDER/res/assets
    # # Create jekyll docker image
    # docker build -t "basti-tee/jekyll" .
    # # Run dockerized jekyll
    # docker run --rm -ti -p 8000:8000 \
    # -v $(pwd)/_includes:/jekyll/_includes \
    # -v $(pwd)/_layouts:/jekyll/_layouts \
    # -v $(pwd)/_plugins:/jekyll/_plugins \
    # -v $(pwd)/_cache:/jekyll/_cache \
    # -v $(pwd)/res:/jekyll/res \
    # -v ${POSTS_FOLDER}:/jekyll/_posts \
    # -v ${POSTS_FOLDER}/res/assets:/jekyll/res/assets \
    # -v ${TARGET_FOLDER}:/jekyll/_site \
    # "basti-tee/jekyll" \
    # $COMMAND
    echo "Docker usage disable for now."
else
    rm -rf _site && ln -s $TARGET_FOLDER _site
    rm -rf _posts && ln -s $POSTS_FOLDER _posts
    rm -rf _drafts && ln -s $DRAFTS_FOLDER _drafts
    rm -rf res/assets && ln -s $ASSETS_FOLDER res/assets
    rm -rf _site && mkdir -p _site
    jekyll $COMMAND -d ${TARGET_FOLDER}
fi
