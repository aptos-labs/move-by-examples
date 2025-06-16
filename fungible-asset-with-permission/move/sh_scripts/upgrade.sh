#!/bin/sh

set -e

echo "##### Upgrade module #####"

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
PUBLISHER_PROFILE=testnet-profile-1

PUBLISHER_ADDR=0x$(aptos config show-profiles --profile=$PUBLISHER_PROFILE | grep 'account' | sed -n 's/.*"account": \"\(.*\)\".*/\1/p')

CONTRACT_ADDRESS=$(cat contract_address.txt)

aptos move upgrade-object-package \
  --object-address $CONTRACT_ADDRESS \
  --named-addresses permissioned_fa_addr=$CONTRACT_ADDRESS \
  --profile $PUBLISHER_PROFILE \
  --assume-yes
