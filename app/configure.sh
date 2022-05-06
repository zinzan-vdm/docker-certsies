#!/bin/bash

set -e

source /app/helper-scripts/template.helper.sh
source /app/helper-scripts/strip-whitespace.helper.sh
source /app/helper-scripts/split-on.helper.sh

if [[ -z "$DEHYDRATED_EMAIL" ]]; then
  echo 'DEHYDRATED_EMAIL is required to configure and register with ACME.'
  exit 1
fi

CERTSIES_DIR="${1-/certsies}"

mkdir -p "$CERTSIES_DIR/wellknown"
mkdir -p "$CERTSIES_DIR/certs"
mkdir -p "$CERTSIES_DIR/accounts"

template-file /app/templates/dehydrate-config > "$CERTSIES_DIR/config"
