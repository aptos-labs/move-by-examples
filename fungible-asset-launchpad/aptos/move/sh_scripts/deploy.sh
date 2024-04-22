#!/bin/sh

set -e

echo "##### Deploy module under a new object #####"

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
PUBLISHER_PROFILE=testnet-profile-1

PUBLISHER_ADDR=0x$(aptos config show-profiles --profile=$PUBLISHER_PROFILE | grep 'account' | sed -n 's/.*"account": \"\(.*\)\".*/\1/p')

OUTPUT=$(aptos move create-object-and-publish-package \
  --address-name launchpad_addr \
  --named-addresses launchpad_addr=$PUBLISHER_ADDR \
  --profile $PUBLISHER_PROFILE \
	--assume-yes)

# Extract the deployed contract address and save it to a file
echo "$OUTPUT" | grep "Code was successfully deployed to object address" | awk '{print $NF}' | sed 's/\.$//' > contract_address.txt
echo "Contract deployed to address: $(cat contract_address.txt)"
echo "Contract address saved to contract_address.txt"
