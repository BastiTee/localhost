FROM alpine
LABEL version="1.0"
LABEL description="Docker image containing a minimal jekyll/ruby setup."
LABEL maintainer="basti.tee@posteo.de"
# Refresh packages
RUN apk upgrade --update
# Base system components
RUN apk add \
libatomic readline readline-dev libxml2 libxml2-dev \
ncurses-terminfo-base ncurses-terminfo \
libxslt libxslt-dev zlib-dev zlib \
ruby-full ruby-dev yaml yaml-dev \
libffi-dev build-base git nodejs \
ruby-io-console ruby-irb ruby-json ruby-rake
# Required ruby gems
RUN gem install --no-document \
redcarpet kramdown maruku rdiscount RedCloth liquid pygments.rb sass safe_yaml \
nokogiri
# Jekyll main component
RUN gem install --no-document jekyll -v 2.5 
# Jekyll plugins
RUN gem install jekyll-paginate jekyll-sass-converter jekyll-sitemap \
jekyll-feed jekyll-redirect-from
# Installation clean up
RUN rm -rf /root/src /tmp/* /usr/share/man /var/cache/apk/*
RUN apk del \
build-base zlib-dev ruby-dev readline-dev \
yaml-dev libffi-dev libxml2-dev
# Index refresh
RUN apk search --update
# Jekyll setup
RUN mkdir /jekyll
COPY _config.yml /jekyll/_config.yml
COPY index.md /jekyll/index.md
COPY feed.xml /jekyll/feed.xml
# Working preparation
WORKDIR /jekyll
EXPOSE 8000
ENTRYPOINT ["jekyll"]
