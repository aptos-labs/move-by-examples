#!/bin/sh

set -e

echo "##### Running tests #####"

# You need to checkout to randomnet branch in aptos-core and build the aptos cli manually
# This is a temporary solution until we have a stable release randomnet cli
aptos move test \
  --package-dir move \
  --dev
