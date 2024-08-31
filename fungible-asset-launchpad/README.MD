# Fungible Asset Launchpad

## Overview

Anyone can create new token, discover tokens created by others and mint them.

## Aptos Specific Things

Mint ref of each fungible asset is stored in the fungible asset object owned by the launchpad contract.

Additionally, to make the contract easier to query without an indexer, we created registry for all created assets.
In production, we would use off-chain indexer to store the registry so it's more performant.

We deployed an instance of it on Aptos testnet, you can access the frontend at https://fungible-asset-launchpad.vercel.app/

And check the contract on explorer https://explorer.aptoslabs.com/object/0x34b00c95aab63fbb3683e27b022d668b4d87c887438bd90ebbdb71356f7acb91?network=testnet

## Solana Specific Things

Mint authority is controlled by PDA to enable permissionless mint.
