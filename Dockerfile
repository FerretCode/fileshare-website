FROM ruby:3.3.5-alpine

RUN apk add --update alpine-sdk postgresql-dev

RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
COPY .env ./
RUN gem install bundler
RUN bundle install

COPY . . 

EXPOSE 4567

CMD [ "bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567" ]
