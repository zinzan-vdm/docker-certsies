#!/bin/sh

set -e

apk update

/app/installers/.install-build-deps.sh
/app/installers/.install-runtime-deps.sh
/app/installers/.install-lexicon.sh
/app/installers/.install-dehydrated.sh

apk del .build-deps
