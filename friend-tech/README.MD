# Friend Tech

## Overview

Anyone can issue its own key, buy and sell keys issued by him/herself or others.

## Aptos Specific Things

Issuer data is stored in Object where seed is issuer's public key.

Holding data is stored in Object where seed is issuer's public key + holder's public key.

Additionally, to make the contract easier to query without an indexer, we created registry for all issuers, all holders for each issuer and all holdings for each user.
In production, we would use off-chain indexer to store the registry so it's more performant.

There's a simple frontend for the app, deployed [here](https://aptos-move-friends.vercel.app/).

The Aptos version of the code in this repo is deprecated, see the [latest version in create-aptos-dapp](https://github.com/aptos-labs/create-aptos-dapp/tree/main/examples/aptos-friend).

## Solana Specific Things

Issuer data is stored in PDA where seed is issuer's public key.

Holding data is stored in PDA where seed is issuer's public key + holder's public key.
