#!/bin/bash

set -e

source /app/helper-scripts/template.helper.sh

if [[ -z "$DEHYDRATED_EMAIL" ]]; then
  echo 'DEHYDRATED_EMAIL is required to configure and register with ACME.'
  exit 1
fi

CERTSIES_DIR="${1-/certsies}"

echo "Creating basic/required directories in $CERTSIES_DIR/config."

mkdir -p "$CERTSIES_DIR/wellknown"
mkdir -p "$CERTSIES_DIR/certs"
mkdir -p "$CERTSIES_DIR/accounts"

if [[ -d /conf ]]; then
  echo "Located directory /conf on the filesystem. Any files inside this folder will now be copied to $CERTSIES_DIR."
  cp -r /conf/* "$CERTSIES_DIR"
fi

if [[ -f $DOMAINS_TXT_PATH ]]; then
  echo "Config specifies DOMAINS_TXT_PATH ($DOMAINS_TXT_PATH), copying file to $CERTSIES_DIR/domains.txt."
  cp "$DOMAINS_TXT_PATH" "$CERTSIES_DIR/domains.txt"
fi

echo "Generating $CERTSIES_DIR/config."

template-file /app/templates/dehydrate-config > "$CERTSIES_DIR/config"
