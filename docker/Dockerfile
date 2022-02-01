# This is a multi-stage build with two stages, where the first is used to precompile assets.
FROM ruby:2.7.5 AS pre-build

# For development docker-compose file overrides ARGS
ARG BUNDLE_WITHOUT="development:test"
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}
ENV BUNDLER_VERSION=2.1.2

ARG RAILS_ENV=production
ENV RAILS_ENV ${RAILS_ENV}

ENV BUNDLE_PATH="/gems"
ARG DB_ADAPTER=nulldb
ENV DB_ADAPTER ${DB_ADAPTER}

ENV SECRET_KEY_BASE="1fe25dabb16153b60531917dce0f70e385be7e4f2581e62f10d91a94999de04225b3363b95bbc2b5967902d60be5dc85ae7661f13d325dcdc44dce4b7756c55e"

# AWS requires a lot of keys to initialize.
ENV AWS_ACCESS_KEY_ID=access_key_id_from_aws
ENV AWS_SECRET_ACCESS_KEY=secret_access_key_from_aws
ENV AWS_REGION=us-east-1
ENV AWS_BUCKET=bucket_name_from_aws

RUN apt-get update && apt-get install -y \
  && apk add \
  nodejs \
  yarn \
  && mkdir -p /var/app \
  && gem install bundler

WORKDIR /app

# Begin by installing gems.
COPY Gemfile Gemfile.lock ./

# Do not install development or test gems in production
RUN if [ "$RAILS_ENV" = "production" ]; then \
  bundle config set without 'development test'; bundle install -j 4 -r 3; \
  else bundle install -j 4 -r 3; \
  fi

# Install JS dependencies using Yarn.
COPY package.json yarn.lock ./
# RUN corepack enable
RUN yarn install

# Copy over remaining files and set up for precompilation.
COPY . /app

# generate production assets if production environment
# Export the locales.json file.
# Compile ReScript files to JS.
# Before precompiling, let's remove bin/yarn to prevent reinstallation of deps via yarn.
RUN if [ "$RAILS_ENV" = "production" ]; then \
  bundle exec i18n export \
  && yarn run re:build \
  && rm bin/yarn \
  && SECRET_KEY_BASE="${SECRET_KEY_BASE}" RAILS_LOG_TO_STDOUT=enabled bundle exec rake assets:precompile \
  && rm -rf spec node_modules tmp/cache; \
  fi

# Remove unnecessary files
RUN rm -rf /gems/ruby/2.7.5/cache/*.gem \
  && find /gems/ruby/2.7.5/gems/ \( -name "*.c" -o -name "*.o" \) -delete

# With precompilation done, we can move onto the final stage.
FROM ruby:2.7.5-slim

# We'll need the PostgreSQL client in this image.
RUN apt-get update && apt-get install -y \
  cron \
  curl \
  postgresql-client \
  imagemagick \
  && gem install bundler \
  && rm -rf /var/lib/apt/lists/*

RUN if [ "$RAILS_ENV" != "production" ]; then \
  apt-get install -y \
  nodejs \
  yarn \
  fi

COPY --from=pre-build /gems/ /gems/
COPY --from=pre-build /app /app

WORKDIR /app

EXPOSE 3000
