FROM elixir:1.10.3-alpine

RUN apk update && apk upgrade \
               && apk add bash nodejs nodejs-npm git \
               && npm install npm webpack -g --no-progress

# Add local node module binaries to PATH
ENV PATH=./node_modules/.bin:$PATH

ADD . /the_crawler
WORKDIR /the_crawler

RUN mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get \
    && MIX_ENV=prod mix compile \
    && cd assets && npm install -D && cd .. \
    && npm run deploy --prefix ./assets \
    && mix phx.digest \
    && MIX_ENV=prod mix release ec

FROM elixir:1.10.3-alpine
COPY --from=0 /the_crawler/_build/prod/rel/ec/ /the_crawler

RUN apk update && apk upgrade && apk add bash
WORKDIR /the_crawler

EXPOSE 4000
CMD /the_crawler/ec/bin/ec start
