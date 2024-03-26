#!/bin/sh

set -e

echo "##### Create a resource account and publishing module under it #####"

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
PUBLISHER_PROFILE=testnet-profile-1

# Resource account seed is the seed used to derive the resource account address
# It can be any string, but it should be unique for each resource account
# RESOURCE_ACCOUNT_SEED=resource-account-seed-2

PUBLISHER_ADDR=0x$(aptos config show-profiles --profile=$PUBLISHER_PROFILE | grep 'account' | sed -n 's/.*"account": \"\(.*\)\".*/\1/p')

echo $PUBLISHER_ADDR

# RESOURCE_ACCOUNT_ADDR=0x$(aptos account derive-resource-account-address \
#   --address $PUBLISHER_ADDR \
#   --seed $RESOURCE_ACCOUNT_SEED \
#   | jq -r '.Result')

# aptos move create-resource-account-and-publish-package \
#   --address-name $PUBLISHER_ADDR \
#   --seed $RESOURCE_ACCOUNT_SEED \
# 	--assume-yes \
#   --profile $PUBLISHER_PROFILE \
#   --named-addresses simple_todo_list_addr=$RESOURCE_ACCOUNT_ADDR

aptos move compile \
  --named-addresses simple_todo_list_addr=$PUBLISHER_ADDR

aptos move create-object-and-publish-package \
  --profile $PUBLISHER_PROFILE \
  --address-name simple_todo_list_addr \
  --named-addresses my_module=$PUBLISHER_ADDR \
	--assume-yes
