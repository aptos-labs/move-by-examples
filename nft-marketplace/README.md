# NFT Marketplace

## Overview

Anyone can mint new NFT from Aptogotchi collection, list NFT and buy NFT.

## Aptos Specific Things

Mint ref of each fungible asset is stored in the fungible asset object owned by the launchpad contract.

Additionally, to make the contract easier to query without an indexer, we created registry for all created assets.
In production, we would use off-chain indexer to store the registry so it's more performant.

There's a simple frontend for the marketplace, deployed [here](https://marketplace-example-rho.vercel.app/).
