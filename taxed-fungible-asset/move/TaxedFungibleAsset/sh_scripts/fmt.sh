#!/bin/sh

set -e

echo "##### Lint and format #####"

aptos move fmt

aptos move lint \
  --named-addresses taxed_fa_addr=0x10000,kc=0x2000000 # dummy address
