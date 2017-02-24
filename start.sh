#!/bin/bash

# cd to script's dir
cd "$( dirname "$( readlink -f "$0" )")"

# create copies of default files
[ ! -d "_post" ] && {
    cp -r _posts.default _posts
}
for file in _config.yml _includes/site-ext.html _includes/footer.html
do
    [ ! -f "$file" ] && {
        cp ${file}.default ${file}
    }
done

# startup jekyll
jekyll server --watch --host localhost --port 8000

# cleanup 
rm -rf _site
