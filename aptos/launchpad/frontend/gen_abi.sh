#! /bin/bash

NETWORK=testnet

CONTRACT_ADDRESS=$(cat ../move/contract_address.txt)

PACKAGE_NAME=$(cat ../move/sources/$(ls ../move/sources/ | head -n 1) | head -n 1 | sed -n 's/module [^:]*::\(.*\) {/\1/p')

echo "export const ABI = $(curl https://fullnode.$NETWORK.aptoslabs.com/v1/accounts/$CONTRACT_ADDRESS/module/$PACKAGE_NAME | sed -n 's/.*"abi":\({.*}\).*}$/\1/p') as const" > src/utils/abi.ts
