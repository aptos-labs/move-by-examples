#!/bin/sh

set -e

echo "##### Running move script to register the pool in 1 tx #####"

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
SENDER_PROFILE=mainnet-profile-1

CONTRACT_ADDRESS=$(cat ../FungibleAssetWithBuySellTax/contract_address.txt)

echo $CONTRACT_ADDRESS

# Need to compile the package first
# note this script only relies on tfa contract address, we can use dummy value for other addresses
aptos move compile \
  --named-addresses taxed_fa_addr=$CONTRACT_ADDRESS,tfa_recipient_addr=0x20,thala_swap_v2_interface_addr=0x30,thala_swap_v2_router_interface_addr=0x40

# Run the script
aptos move run-script \
	--assume-yes \
  --profile $SENDER_PROFILE \
  --compiled-script-path build/ScriptsOnly/bytecode_scripts/register_pool_1.mv
