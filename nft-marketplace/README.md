# NFT Marketplace

## Overview

Anyone can mint new NFT from Aptogotchi collection, list NFT and buy NFT.

## Aptos Specific Things

Mint ref of each fungible asset is stored in the fungible asset object owned by the launchpad contract.

Additionally, to make the contract easier to query without an indexer, we created registry for all created assets.
In production, we would use off-chain indexer to store the registry so it's more performant.

There's a simple frontend for the marketplace, deployed [here](https://marketplace-example-rho.vercel.app/).

## Env setup

Check out the guide from [Aptos Learn](https://learn.aptoslabs.com/example/aptogotchi-beginner/env-setup).

## Play with testnet deployments on explorer

Go to testnet explorer [here](https://explorer.aptoslabs.com/?network=testnet) and search for the contract address.

You can find the contract address in each contract directory's `contract_address.txt`.

On explorer, you can read the contract code, call entry functions (need to connect wallet), and call view functions.

## Development

In each contract's `move` directory, you can run below commands.

Run unit test

```sh
./sh_scripts/test.sh
```

Deploy to testnet

```sh
./sh_scripts/deploy.sh
```

Upgrade deployed contract

```sh
./sh_scripts/upgrade.sh
```

Run Move scripts. Move scripts are off-chain Move functions that let you call multiple functions atomically, it's similar to how you group multiple instructions in 1 transaction on Solana.

```sh
# You can explorer what other scripts are available in sh_scripts
./sh_scripts/create_and_mint_some_fas.sh
```
