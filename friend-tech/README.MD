# Friend Tech

## Overview

Exactly like Friend.Tech, anyone can issue its own key, buy and sell keys issued by him/herself or others.

## Aptos Specific Things

Issuer data is stored in Object where seed is issuer's public key.

Holding data is stored in Object where seed is issuer's public key + holder's public key.

Additionally, to make the contract easier to query without an indexer, we created registry for all issuers, all holders for each issuer and all holdings for each user.
In production, we would use off-chain indexer to store the registry so it's more performant.

We deployed an instance of it on Aptos testnet, you can access the frontend at https://aptos-move-friends.vercel.app/

And check the contract on explorer https://explorer.aptoslabs.com/object/0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0?network=testnet

## Solana Specific Things

Issuer data is stored in PDA where seed is issuer's public key.

Holding data is stored in PDA where seed is issuer's public key + holder's public key.
