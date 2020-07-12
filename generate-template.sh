#!/bin/bash
cd "$( cd "$( dirname "$0" )"; pwd )"

if [ -z "$1" ]; then echo "No name given"; exit 1; fi

fname="$( echo $@ |tr "[:upper:]" "[:lower:]" |sed -e "s/ /-/g" )"
new_file="$( pwd )/$( date '+%Y-%m-%d' )-$fname.md"
post_date=$( date '+%Y-%m-%d %H:%M:%S %z' )

cat << EOF > $new_file
---
layout: post
title: '$@'
date: '$post_date'
categories: 
---

# ..

EOF
