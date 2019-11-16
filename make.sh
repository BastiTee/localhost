#!/bin/sh
set -e
cd "$( cd "$( dirname "$0" )"; pwd )"

DEFAULT_COMMAND="server \
--host 0.0.0.0 \
--port 8000 \
--trace \
--incremental \
--drafts \
--open-url \
--watch \
"

print_help() {
    cat << EOF
Usage: $( basename $0 ) [OPTS]

Options:
    -p  DIR     Jekyll _posts folder (default: ./_posts)
    -t  DIR     Jekyll _site folder (default: ./_site)
    -c  CMD     Jekyll command line (default: $DEFAULT_COMMAND)
    -n          Run native instead inside docker
EOF
exit 0
}

while getopts p:t:c:nh opt
do
   case $opt in
       p) POSTS_FOLDER=$OPTARG;;
       t) TARGET_FOLDER=$OPTARG;;
       c) COMMAND="$OPTARG";;
       n) NATIVE=1;;
       h) print_help ;;
       *) print_help ;;
   esac
done
POSTS_FOLDER=${POSTS_FOLDER:-$(pwd)/_posts}
TARGET_FOLDER=${TARGET_FOLDER:-$(pwd)/_site}
NATIVE=${NATIVE:-0}
COMMAND=${COMMAND:-$DEFAULT_COMMAND}
if [ $NATIVE -eq 1 ]; then
    COMMAND=$( echo $COMMAND | sed -e "s/0.0.0.0/localhost/" )
fi
echo "POSTS FOLDER:   $POSTS_FOLDER"
echo "TARGET FOLDER:  $TARGET_FOLDER"
echo "JEKYLL COMMAND: $COMMAND"
echo "NATIVE:         $NATIVE"

# Prepare input/output folders
mkdir -p $TARGET_FOLDER
mkdir -p $POSTS_FOLDER/res/assets
mkdir -p _cache

if [ $NATIVE -eq 0 ]; then 
    # Create jekyll docker image
    docker build -t "basti-tee/jekyll" .
    # Run dockerized jekyll
    docker run --rm -ti -p 8000:8000 \
    -v $(pwd)/_includes:/jekyll/_includes \
    -v $(pwd)/_layouts:/jekyll/_layouts \
    -v $(pwd)/_plugins:/jekyll/_plugins \
    -v $(pwd)/_cache:/jekyll/_cache \
    -v $(pwd)/res:/jekyll/res \
    -v ${POSTS_FOLDER}:/jekyll/_posts \
    -v ${POSTS_FOLDER}/res/assets:/jekyll/res/assets \
    -v ${TARGET_FOLDER}:/jekyll/_site \
    "basti-tee/jekyll" \
    $COMMAND
else
    jekyll $COMMAND -d ${TARGET_FOLDER}
fi
