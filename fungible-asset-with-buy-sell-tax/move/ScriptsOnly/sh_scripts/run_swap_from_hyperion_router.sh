#!/bin/sh

set -e

echo "##### Running move script to swap TFA to APT from thala pool in 1 tx #####"

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
SENDER_PROFILE=mainnet-profile-1

#CONTRACT_ADDRESS=$(cat contract_address.txt)
#
#SENDER_ADDR=0x$(aptos config show-profiles --profile=$SENDER_PROFILE | grep 'account' | sed -n 's/.*"account": \"\(.*\)\".*/\1/p')

# Need to compile the package first
# note this script only relies on thala contract, so we use dummy value for other addresses
aptos move compile \
  --named-addresses taxed_fa_addr=0x10,tfa_recipient_addr=0x20,thala_swap_v2_interface_addr=0x7730cd28ee1cdc9e999336cbc430f99e7c44397c0aa77516f6f23a78559bb5,thala_swap_v2_router_interface_addr=0x30,hyperion_interface_addr=0x8b4a2c4bb53857c718a04c020b98f8c2e1f99a68b0f57389a8bf5434cd22e05c

# Run the script
aptos move run-script \
	--assume-yes \
  --profile $SENDER_PROFILE \
  --compiled-script-path build/ScriptsOnly/bytecode_scripts/swap_from_hyperion_router_3.mv
