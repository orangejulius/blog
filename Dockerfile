FROM ruby:2.3

ENV WORKDIR=/blog
WORKDIR $WORKDIR

COPY Gemfile* $WORKDIR/
RUN bundle install

COPY . $WORKDIR

ENV HOST=0.0.0.0

ENTRYPOINT ["bundle", "exec", "rake"]
CMD [ "preview" ]
