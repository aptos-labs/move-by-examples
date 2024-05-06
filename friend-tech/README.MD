# Friend Tech

## Overview

Anyone can issue its own key, buy and sell keys issued by him/herself or others.

## Aptos Specific Things

Issuer data is stored in Object where seed is issuer's public key.

Holding data is stored in Object where seed is issuer's public key + holder's public key.

Additionally, to make the contract easier to query without an indexer, we created registry for all issuers, all holders for each issuer and all holdings for each user.
In production, we would use off-chain indexer to store the registry so it's more performant.

## Solana Specific Things

Issuer data is stored in PDA where seed is issuer's public key.

Holding data is stored in PDA where seed is issuer's public key + holder's public key.
