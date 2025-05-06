# NFT Launchpad

## Overview

Anyone can create new collection, discover collections created by others and mint them.

## Aptos Specific Things

Mint ref of each fungible asset is stored in the fungible asset object owned by the launchpad contract.

Additionally, to make the contract easier to query without an indexer, we created registry for all created collections.
In production, we would use off-chain indexer to store the registry so it's more performant.

We deployed an instance of it on Aptos testnet, you can access the frontend at https://aptos-nft-launchpad.vercel.app/

And check the contract on explorer https://explorer.aptoslabs.com/object/0x7768e9bcb09adfe6dbbee3a103951ad6199ea2eaa2e7cf78c5feae7a55a0e9d3?network=testnet

## Overview

This example is built using the [NFT minting template in create-aptos-dapp](https://aptos.dev/en/build/create-aptos-dapp/templates/nft-minting-dapp). Comparing to the original template, collection creation is permissionless.

### What tools the template uses?

- React framework
- Vite development tool
- shadcn/ui + tailwind for styling
- Aptos TS SDK
- Aptos Wallet Adapter
- Node based Move commands

### What Move commands are available?

The tool utilizes [aptos-cli npm package](https://github.com/aptos-labs/aptos-cli) that lets us run Aptos CLI in a Node environment.

Some commands are built-in the template and can be ran as a npm script, for example:

- `npm run move:init` - a command to initialize an account to publish the Move contract and to configure the development environment
- `npm run move:publish` - a command to publish the Move contract
- `npm run move:upgrade` - a command to upgrade the Move contract
- `npm run move:test` - a command to run Move unit tests
- `npm run move:compile` - a command to compile the Move contract
- `npm run deploy` - a command to deploy the dapp to Vercel

For all other available CLI commands, can run `npx aptos` and see a list of all available commands.
