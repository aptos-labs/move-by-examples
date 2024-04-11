#!/bin/sh

set -e

echo "##### Upgrade module #####"

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
PUBLISHER_PROFILE=testnet-profile-1

PUBLISHER_ADDR=0x$(aptos config show-profiles --profile=$PUBLISHER_PROFILE | grep 'account' | sed -n 's/.*"account": \"\(.*\)\".*/\1/p')

# to fill, you can find it from the output of deployment script
ADVANCED_TODO_LIST_CONTRACT_OBJECT_ADDR="0x65ab5f8c243471af66967b1780e6e1d7710cb7b676545dac5652a2fbed0143fb"
aptos move upgrade-object-package \
  --object-address $ADVANCED_TODO_LIST_CONTRACT_OBJECT_ADDR \
  --named-addresses advanced_todo_list_addr=$ADVANCED_TODO_LIST_CONTRACT_OBJECT_ADDR \
  --profile $PUBLISHER_PROFILE \
  --assume-yes
