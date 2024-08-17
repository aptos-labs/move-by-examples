# NFT Launchpad

## Overview

Anyone can create new collection, discover collections created by others and mint them.

## Aptos Specific Things

Mint ref of each fungible asset is stored in the fungible asset object owned by the launchpad contract.

Additionally, to make the contract easier to query without an indexer, we created registry for all created collections.
In production, we would use off-chain indexer to store the registry so it's more performant.

We deployed an instance of it on Aptos testnet, you can access the frontend at https://aptos-nft-launchpad.vercel.app/

And check the contract on explorer https://explorer.aptoslabs.com/object/0x7768e9bcb09adfe6dbbee3a103951ad6199ea2eaa2e7cf78c5feae7a55a0e9d3?network=testnet
