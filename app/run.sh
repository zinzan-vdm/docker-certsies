#!/bin/bash

set -e

CERTSIES_DIR="/certsies"

if [[ "$CONFIGURE" == 'yes' ]]; then
  echo 'Configuring Dehydrated.'
  /app/configure.sh "$CERTSIES_DIR"
fi

if [[ "$DEHYDRATED_ACCEPT_TERMS" == "yes" ]]; then
  echo 'Accepting terms.'
	dehydrated --config "$CERTSIES_DIR/config" --register --accept-terms
fi

echo 'Executing Dehydrated.'
dehydrated --config "$CERTSIES_DIR/config" --cron --keep-going
