#!/bin/sh

set -e

echo "##### Publishing module #####"

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
PROFILE=testnet-profile-6

# Resource account seed is the seed used to derive the resource account address
# It can be any string, but it should be unique for each resource account
RESOURCE_ACCOUNT_SEED=resource-account-seed-1

ADDR=0x$(aptos config show-profiles --profile=$PROFILE | grep 'account' | sed -n 's/.*"account": \"\(.*\)\".*/\1/p')

RESOURCE_ACCOUNT_ADDR=0x$(aptos account derive-resource-account-address \
  --address $ADDR \
  --seed $RESOURCE_ACCOUNT_SEED \
  | jq -r '.Result')

aptos move create-resource-account-and-publish-package \
  --address-name $ADDR\
  --seed $RESOURCE_ACCOUNT_SEED \
	--assume-yes \
  --profile $PROFILE \
  --named-addresses marketplace=$RESOURCE_ACCOUNT_ADDR
