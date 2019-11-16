#!/bin/sh
cd "$( cd "$( dirname "$0" )"; pwd )"

[ ! -f _config.yml ] && cp _config.yml.default _config.yml
docker build -t "basti-tee/jekyll" .

mkdir -p _site

docker run --rm -ti -p 8000:8000 \
-v $(pwd)/_includes:/jekyll/_includes \
-v $(pwd)/_layouts:/jekyll/_layouts \
-v $(pwd)/_plugins:/jekyll/_plugins \
-v $(pwd)/_posts:/jekyll/_posts \
-v $(pwd)/_site:/jekyll/_site \
-v $(pwd)/res:/jekyll/res \
-v $(pwd)/_posts/res/assets:/jekyll/res/assets \
"basti-tee/jekyll" \
server --host 0.0.0.0 --port 8000
