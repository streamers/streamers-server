FROM oivoodoo/elixir:latest

WORKDIR /app

ADD http://s3.amazonaws.com/s3.hex.pm/installs/1.1.0/hex-0.15.0.ez /tmp/
RUN mix archive.install --force /tmp/hex-0.15.0.ez
