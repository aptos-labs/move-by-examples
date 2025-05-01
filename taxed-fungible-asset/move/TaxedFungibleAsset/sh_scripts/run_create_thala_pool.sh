#!/bin/sh

set -e

echo "##### Running move script to create a APT-TFA pool on thala in 1 tx #####"

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
SENDER_PROFILE=mainnet-profile-1

#CONTRACT_ADDRESS=$(cat contract_address.txt)
#
#SENDER_ADDR=0x$(aptos config show-profiles --profile=$SENDER_PROFILE | grep 'account' | sed -n 's/.*"account": \"\(.*\)\".*/\1/p')

# Need to compile the package first
# note this script only relies on thala contract, so we use dummy address for other addresses
aptos move compile \
  --named-addresses taxed_fa_addr=0x10,tfa_recipient_addr=0x20,thala_swap_v2_interface_addr=0x7730cd28ee1cdc9e999336cbc430f99e7c44397c0aa77516f6f23a78559bb5

# Run the script
aptos move run-script \
	--assume-yes \
  --profile $SENDER_PROFILE \
  --compiled-script-path build/taxed_fa/bytecode_scripts/create_thala_pool_0.mv
