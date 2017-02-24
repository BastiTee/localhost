#!/bin/bash

# cd to script's dir
cd "$( dirname "$( readlink -f "$0" )")"

cat .gitignore | while read entry
do
    if [ -e $entry ]; then
        echo "removing $entry"
        rm -rf $entry
    fi
done
