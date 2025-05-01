#! /bin/bash

NETWORK=testnet

CONTRACT_ADDRESS=$(cat ./contract_address.txt)

for file in "./sources"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        module_name="${filename%.*}"
        echo "getting abi for module $module_name"

        ABI="export const ABI = $(curl https://fullnode.$NETWORK.aptoslabs.com/v1/accounts/$CONTRACT_ADDRESS/module/$module_name | sed -n 's/.*"abi":\({.*}\).*}$/\1/p') as const"

        NEXT_APP_ABI_DIR="../../../next-app/src/lib/abi"
        mkdir -p $NEXT_APP_ABI_DIR
        echo $ABI >$NEXT_APP_ABI_DIR/${module_name}_abi.ts

        NODE_SCRIPTS_ABI_DIR="../../../node-script/src/lib/abi"
        mkdir -p $NODE_SCRIPTS_ABI_DIR
        echo $ABI >$NODE_SCRIPTS_ABI_DIR/${module_name}_abi.ts

        TS_INDEXER_ABI_DIR="../../../ts-indexer/src/abi"
        mkdir -p $TS_INDEXER_ABI_DIR
        echo $ABI >$TS_INDEXER_ABI_DIR/${module_name}_abi.ts
    fi
done
