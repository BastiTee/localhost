#!/bin/bash
cd "$( cd "$( dirname "$0" )"; pwd )"

echo "Creating copies of default files..."
for file in \
_posts \
_config.yml \
_includes/site-ext.html \
_includes/footer.html \
_includes/script.js
do
    if [ -L "$file" ]; then
        echo "File $file present as symlink."
    elif [ -e "$file" ]; then
        echo "File $file already present."
    else
        echo "Will copy $file from default."
        cp -vr ${file}.default ${file}
    fi
done

echo "Creating resource folder..."
mkdir -vp res/blogres

echo "Creating docker image..."
docker build -t "basti-tee/jekyll" .
docker run --rm \
-v $(pwd):/workdir \
-p 8000:8000 \
"basti-tee/jekyll" \
server \
--source /workdir \
--destination /workdir/_site \
--layouts /workdir/_layouts \
--plugins /workdir/_plugins \
--port 8000 \
--host 0.0.0.0
