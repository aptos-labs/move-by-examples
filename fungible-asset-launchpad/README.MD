# Simple Todo List

## Overview

Anyone can create new token, discover tokens created by others and mint them.

## Aptos Specific Things

Mint ref of each fungible asset is stored in the fungible asset object owned by the launchpad contract.

There's a simple frontend for the launchpad, deployed [here](https://fungible-asset-launchpad.vercel.app/).

## Solana Specific Things

Mint authority is controlled by PDA to enable permissionless mint.
