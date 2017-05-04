FROM ruby:2.4.1-alpine

ADD Gemfile /app/
ADD Gemfile.lock /app/
ADD presencebot.rb /app/

RUN apk update && apk upgrade && apk add --virtual build-dependencies ruby-dev build-base && apk add openssl && gem install bundler --no-ri --no-rdoc && cd app/ && bundle install

RUN chown -R nobody:nogroup /app  
USER nobody  
WORKDIR /app

CMD ruby presencebot.rb
