#!/bin/sh

set -e

echo "##### Upgrade module #####"

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
PUBLISHER_PROFILE=testnet-profile-1

PUBLISHER_ADDR=0x$(aptos config show-profiles --profile=$PUBLISHER_PROFILE | grep 'account' | sed -n 's/.*"account": \"\(.*\)\".*/\1/p')

# to fill, you can find it from the output of deployment script
SIMPLE_TODO_LIST_CONTRACT_OBJECT_ADDR="0xdeb9fd0a4ca01e848f978ee5191595d7ee859c450b5e51629f04dec9b7560e60"
aptos move upgrade-object-package \
  --object-address $SIMPLE_TODO_LIST_CONTRACT_OBJECT_ADDR \
  --named-addresses simple_todo_list_addr=$SIMPLE_TODO_LIST_CONTRACT_OBJECT_ADDR \
  --profile $PUBLISHER_PROFILE \
  --assume-yes
