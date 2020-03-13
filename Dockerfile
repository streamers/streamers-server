FROM elixir:1.10-alpine

WORKDIR /app

RUN apk add git

ADD http://s3.amazonaws.com/s3.hex.pm/installs/1.1.0/hex-0.20.5.ez /tmp/
RUN mix archive.install --force /tmp/hex-0.20.5.ez

RUN mix local.rebar --force
