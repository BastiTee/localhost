#!/bin/sh
cd "$( cd "$( dirname "$0" )"; pwd )"

[ ! -f _config.yml ] && cp _config.yml.default _config.yml
docker build -t "basti-tee/jekyll" .

# notebook="/Users/sebastiantschoepel/nextcloud/Notebook/Backup"

mkdir -p _site

docker run --rm -ti -p 8000:8000 \
-v $(pwd)/_posts:/jekyll/_posts \
-v $(pwd)/_includes:/jekyll/_includes \
-v $(pwd)/_layouts:/jekyll/_layouts \
-v $(pwd)/_plugins:/jekyll/_plugins \
-v $(pwd)/_site:/jekyll/_site \
"basti-tee/jekyll" \
# server \
# --port 8000 \
# --host 0.0.0.0 \
