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
ruby-io-console ruby-irb ruby-json ruby-rake su-exec
# Required ruby gems
RUN gem install --no-document \
redcarpet kramdown maruku rdiscount RedCloth liquid pygments.rb sass safe_yaml \
nokogiri jekyll jekyll-paginate jekyll-sass-converter jekyll-sitemap \
jekyll-feed jekyll-redirect-from jekyll-toc
# Installation clean up
RUN rm -rf /root/src /tmp/* /usr/share/man /var/cache/apk/*
RUN apk del \
build-base zlib-dev ruby-dev readline-dev \
yaml-dev libffi-dev libxml2-dev
# Index refresh
RUN apk search --update

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Working preparation
EXPOSE 50600 50601

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

