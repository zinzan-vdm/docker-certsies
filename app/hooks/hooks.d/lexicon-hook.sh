#!/bin/bash

set -e
set -u
set -o pipefail

if [[ "$DEHYDRATED_CHALLENGE" != 'dns-01' ]]; then
  echo 'LEXICON Hook not required unless DEHYDRATED_CHALLENGE is set to dns-01'
  exit 0
fi

PROVIDER=${LEXICON_PROVIDER-cloudflare}

LEXICON_CONFIG_DIR='/certsies'
if [[ -f $LEXICON_YML_PATH ]]; then
  LEXICON_CONFIG_DIR="$(dirname "$LEXICON_YML_PATH")"
fi

echo "LEXICON Hook Executing -> $@"

function deploy_challenge {
  # This hook is called once for every domain that needs to be
  # validated, including any alternative names you may have listed.
  #
  # Parameters:
  # - DOMAIN
  #   The domain name (CN or subject alternative name) being
  #   validated.
  # - TOKEN_FILENAME
  #   The name of the file containing the token to be served for HTTP
  #   validation. Should be served by your web server as
  #   /.well-known/acme-challenge/${TOKEN_FILENAME}.
  # - TOKEN_VALUE
  #   The token value that needs to be served for validation. For DNS
  #   validation, this is what you want to put in the _acme-challenge
  #   TXT record. For HTTP validation it is the value that is expected
  #   be found in the $TOKEN_FILENAME file.

  local DOMAIN="${1}"
  local TOKEN_FILENAME="${2}"
  local TOKEN_VALUE="${3}"

  echo "LEXICON: [deploy_challenge] (domain: $DOMAIN, token_file: $TOKEN_FILENAME, token_value: $TOKEN_VALUE)"
  echo "LEXICON:   Deploying challenge record for $DOMAIN (_acme-challenge.$DOMAIN.)."
  echo "LEXICON:     Config directory: $LEXICON_CONFIG_DIR"
  echo "LEXICON:     Provider: $PROVIDER"

  lexicon --config-dir="$LEXICON_CONFIG_DIR" "$PROVIDER" create "$DOMAIN" TXT --name="_acme-challenge.$DOMAIN." --content="${TOKEN_VALUE}"

  sleep 30
}

function clean_challenge {
  # This hook is called after attempting to validate each domain,
  # whether or not validation was successful. Here you can delete
  # files or DNS records that are no longer needed.
  #
  # The parameters are the same as for deploy_challenge.

  local DOMAIN="${1}"
  local TOKEN_FILENAME="${2}"
  local TOKEN_VALUE="${3}"

  echo "LEXICON: [clean_challenge] (domain: $DOMAIN, token_file: $TOKEN_FILENAME, token_value: $TOKEN_VALUE)"
  echo "LEXICON:   Removing challenge record for $DOMAIN (TXT _acme-challenge.$DOMAIN.)."
  echo "LEXICON:     Config directory: $LEXICON_CONFIG_DIR"
  echo "LEXICON:     Provider: $PROVIDER"

  lexicon --config-dir="$LEXICON_CONFIG_DIR" "$PROVIDER" delete "$DOMAIN" TXT --name="_acme-challenge.$DOMAIN." --content="${TOKEN_VALUE}"
}

function invalid_challenge() {
  # This hook is called if the challenge response has failed, so domain
  # owners can be aware and act accordingly.
  #
  # Parameters:
  # - DOMAIN
  #   The primary domain name, i.e. the certificate common
  #   name (CN).
  # - RESPONSE
  #   The response that the verification server returned

  local DOMAIN="${1}"
  local RESPONSE="${2}"

  echo "LEXICON: [invalid_challenge] (domain: $DOMAIN, response: $RESPONSE)"
}

function deploy_cert {
  # This hook is called once for each certificate that has been
  # produced. Here you might, for instance, copy your new certificates
  # to service-specific locations and reload the service.
  #
  # Parameters:
  # - DOMAIN
  #   The primary domain name, i.e. the certificate common
  #   name (CN).
  # - KEYFILE
  #   The path of the file containing the private key.
  # - CERTFILE
  #   The path of the file containing the signed certificate.
  # - FULLCHAINFILE
  #   The path of the file containing the full certificate chain.
  # - CHAINFILE
  #   The path of the file containing the intermediate certificate(s).

  local DOMAIN="${1}"
  local KEYFILE="${2}"
  local CERTFILE="${3}"
  local FULLCHAINFILE="${4}"
  local CHAINFILE="${5}"

  echo "LEXICON: [deploy_cert] (domain=$DOMAIN, keyfile=$KEYFILE, certfile=$CERTFILE, fullchainfile=$FULLCHAINFILE, chainfile=$CHAINFILE)"
  echo "LEXICON:   Merging fullchainfile and keyfile into combined.pem"

  cat ${FULLCHAINFILE} ${KEYFILE} > $(dirname ${CERTFILE})/combined.pem

  echo "LEXICON:   Granting rights on the created certificate files to user (r+w), group (r), other (none)."
  chmod 640 "${KEYFILE}" "${CERTFILE}" "${FULLCHAINFILE}" "${CHAINFILE}" "$(dirname ${CERTFILE})/combined.pem"
}

function unchanged_cert {
  # This hook is called once for each certificate that is still
  # valid and therefore wasn't reissued.
  #
  # Parameters:
  # - DOMAIN
  #   The primary domain name, i.e. the certificate common
  #   name (CN).
  # - KEYFILE
  #   The path of the file containing the private key.
  # - CERTFILE
  #   The path of the file containing the signed certificate.
  # - FULLCHAINFILE
  #   The path of the file containing the full certificate chain.
  # - CHAINFILE
  #   The path of the file containing the intermediate certificate(s).

  local DOMAIN="${1}"
  local KEYFILE="${2}"
  local CERTFILE="${3}"
  local FULLCHAINFILE="${4}"
  local CHAINFILE="${5}"

  echo "LEXICON: [unchanged_cert] (domain=$DOMAIN, keyfile=$KEYFILE, certfile=$CERTFILE, fullchainfile=$FULLCHAINFILE, chainfile=$CHAINFILE)"
}

function exit_hook {
  # This hook is called at the end of a dehydrated command and can be used
  # to do some final (cleanup or other) tasks.

  echo "LEXICON: [exit_hook] ()"
}

function startup_hook {
  # This hook is called before the dehydrated command to do some initial tasks
  # (e.g. starting a webserver).

  echo "LEXICON: [startup_hook] ()"
}

HANDLER=$1; shift;
if [ -n "$(type -t $HANDLER)" ] && [ "$(type -t $HANDLER)" = function ]; then
  $HANDLER "$@"
fi
