FROM ruby:2.6.4-alpine3.10
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN apk add --update git curl build-base \
  libxml2-dev libxslt-dev pcre-dev libffi-dev \
  && bundle install \
  && apk update \
  && rm -rf /var/cache/apk/*

COPY . /app

EXPOSE 3000

RUN curl --location --silent https://github.com/gliderlabs/herokuish/releases/download/v0.5.3/herokuish_0.5.3_linux_x86_64.tgz | tar -xzC /bin
