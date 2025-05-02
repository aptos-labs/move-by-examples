#!/bin/sh

set -e

echo "##### Lint and format #####"

aptos move fmt

aptos move lint \
  --named-addresses taxed_fa_addr=0x10,tfa_recipient_addr=0x20,thala_swap_v2_interface_addr=0x30
