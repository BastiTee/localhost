#!/bin/sh

set -e
cd "$( cd "$( dirname "$0" )"; pwd )" # Change to script's dir

# -----------------------------------------------------------------------------

print_help() {
    cat << EOF
Usage: $( basename $0 ) [OPTS]

Options:
    -c  CMD     Command [server,generate,printconf]     
    -e  ENVFILE Environment configuration file (default: config-environment)
EOF
}

while getopts c:e:h opt
do
   case $opt in
       c) CMD=$OPTARG;;
       e) ENVFILE=$OPTARG;;
       h) print_help; exit 0;;
       *) echo "Unknown option."; print_help; exit 1;;
   esac
done

# -----------------------------------------------------------------------------

if [ -z "$CMD" ]; then echo "No command selected!"; print_help; fi
ENVFILE=${ENVFILE:-config-environment}
source $ENVFILE
if [ "$CMD" == "server" ]; then
    export LH_CMD="server --host 0.0.0.0 --port 50600 --incremental 
    --livereload --watch --livereload-port 50601 --trace $LH_ADD_ARGS"
elif [ "$CMD" == "generate" ]; then
    export LH_CMD="build --trace $LH_ADD_ARGS"
elif [ "$CMD" == "printconf" ]; then
    env |grep -e "^LH_*"|sort  # Print configuration
    exit 0
else
    echo "Invalid command name."
    print_help
    exit 1
fi
env |grep -e "^LH_*"|sort  # Print configuration

# -----------------------------------------------------------------------------

# Prepare run environment 
[ $LH_SKIP_DOCKER -eq 0 ] && docker build -t "basti-tee/jekyll" .
mkdir -p $LH_CACHE_FOLDER

# Run dockerized jekyll
docker run --rm -p 50600:50600 -p 50601:50601 \
-e LOCAL_USER_ID=`id -u $USER` \
-v ${LH_YAML_FILE}:/usr/share/jekyll/_config.yml \
-v $(pwd)/index.md:/usr/share/jekyll/index.md \
-v $(pwd)/feed.xml:/usr/share/jekyll/feed.xml \
-v $(pwd)/_includes:/usr/share/jekyll/_includes \
-v $(pwd)/_layouts:/usr/share/jekyll/_layouts \
-v $(pwd)/_plugins:/usr/share/jekyll/_plugins \
-v $(pwd)/res:/usr/share/jekyll/res \
-v ${LH_POSTS_FOLDER}:/usr/share/jekyll/_posts \
-v ${LH_DRAFTS_FOLDER}:/usr/share/jekyll/_drafts \
-v ${LH_ASSETS_FOLDER}:/usr/share/jekyll/res/assets \
-v ${LH_CACHE_FOLDER}:/usr/share/jekyll/_cache \
-v ${LH_TARGET_FOLDER}:/usr/share/jekyll/_site \
"basti-tee/jekyll" \
$LH_CMD
