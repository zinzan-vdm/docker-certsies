#!/bin/sh

set -e

apk add --no-cache --virtual .runtime-deps \
  openssl \
  curl \
  sed \
  gawk \
  grep \
  bash \
  libxml2-utils \
  python3 \
  cmd:pip3

pip3 install --upgrade pip
