## Aptos Friend Example

This example is created from the boilerplate template in create-aptos-dapp.

The Boilerplate template provides a starter dapp with all necessary dapp infrastructure and a simple wallet info implementation.

### Aptos Friend Overview

Aptos friend is inspired by Friend.Tech, which is a social app that enables anyone to tokenize their profile by issuing shares (also know as keys). The price of the share is based on the supply and demand, i.e. price goes up when more people buying the share and vice versa. On top of the share trading, developers can build interesting things on top such as share gated chat, priority chat based on number of shares hold, etc.

You can find a detailed explanation on the contract on [Aptos Learn](https://learn.aptoslabs.com/en/tutorial/solana-to-aptos-guide/move-friend/demo?workshop=solana-to-aptos).

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
- `npm run move:get-abi` - a command to download the ABI of the contract
- `npm run move:issue-share-and-buy-share` - a command to run a Move script that will issue share and buy share in one transaction

For all other available CLI commands, can run `npx aptos` and see a list of all available commands.
