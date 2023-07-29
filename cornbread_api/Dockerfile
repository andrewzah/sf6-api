FROM ruby:3.1.2

RUN gem install rails bundler

# Default directory
ENV INSTALL_PATH "/app"
RUN mkdir -p "$INSTALL_PATH"

WORKDIR $INSTALL_PATH
COPY ./ .

RUN bundle install

CMD bundle exec rails server
