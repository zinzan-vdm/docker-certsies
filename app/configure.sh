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
  echo "Located directory /conf on the filesystem. Any files inside this folder will now be copied to the $CERTSIES_DIR."
  cp -r /conf/* "$CERTSIES_DIR"
fi

if [[ ! -z $DOMAINS_TXT && -f $DOMAINS_TXT ]]; then
  echo "Config specifies DOMAINS_TXT ($DOMAINS_TXT), copying file to $CERTSIES_DIR."
  cp "$DOMAINS_TXT" "$CERTSIES_DIR/domains.txt"
fi

if [[ ! -z $LEXICON_YML && -f $LEXICON_YML ]]; then
  echo "Config specifies LEXICON_YML ($LEXICON_YML), copying file to $CERTSIES_DIR."
  cp "$LEXICON_YML" "$CERTSIES_DIR/lexicon.yml"
fi

echo "Generating $CERTSIES_DIR/config."

template-file /app/templates/dehydrate-config > "$CERTSIES_DIR/config"
