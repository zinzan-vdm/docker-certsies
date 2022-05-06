#!/bin/sh

set -e

apk add --no-cache --virtual .build-deps \
  git \
  python3-dev \
  libffi-dev \
  build-base \
  openssl-dev 
