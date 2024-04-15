#!/bin/sh

set -e

echo "##### Running move script to create and mint some FAs in 1 tx #####"

CONTRACT_ADDRESS=$(cat contract_address.txt)

# Need to compile the package first
aptos move compile \
  --named-addresses launchpad_addr=$CONTRACT_ADDRESS

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
SENDER_PROFILE=testnet-profile-1

# Run the script
aptos move run-script \
	--assume-yes \
  --profile $SENDER_PROFILE \
  --compiled-script-path build/launchpad/bytecode_scripts/create_and_mint_some_fas.mv
