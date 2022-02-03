# This is a multi-stage build with two stages, where the first is used to precompile assets.
FROM ruby:2.7.5

WORKDIR /app

ARG RAILS_ENV=development
ENV RAILS_ENV ${RAILS_ENV}

# We need NodeJS for precompiling assets.
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends openssl imagemagick autoconf libtool curl postgresql-client imagemagick git

COPY Gemfile .
COPY Gemfile.lock .
RUN gem install bundler -v '2.2.33'
RUN bundle install -j4

COPY package.json .
COPY yarn.lock .
RUN corepack enable
RUN yarn install

COPY . /app
