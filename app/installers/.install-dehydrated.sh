#!/bin/sh

set -e

mkdir -p /opt
git clone https://github.com/dehydrated-io/dehydrated.git /opt/dehydrated

chmod -R 555 /opt/dehydrated/dehydrated

ln -s /opt/dehydrated/dehydrated /bin/dehydrated
