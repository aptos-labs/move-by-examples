#!/bin/sh

set -e

echo "##### Deploy module under a new object #####"

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
PUBLISHER_PROFILE=testnet-profile-1

PUBLISHER_ADDR=0x$(aptos config show-profiles --profile=$PUBLISHER_PROFILE | grep 'account' | sed -n 's/.*"account": \"\(.*\)\".*/\1/p')

aptos move create-object-and-publish-package \
  --address-name simple_todo_list_addr \
  --named-addresses simple_todo_list_addr=$PUBLISHER_ADDR \
  --profile $PUBLISHER_PROFILE \
	--assume-yes
