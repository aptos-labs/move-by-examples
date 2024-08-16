## Create Aptos Dapp Fungible Asset Template

The Fungible Asset template provides an end-to-end Fungible Asset minting dapp with a beautiful pre-made UI users can quickly adjust and deploy into a live server.

Read more about how to use the template [here](https://aptos.dev/create-aptos-dapp/templates/fungible-asset)

## The Fungible Asset template provides 3 pages:

- **Public Mint Fungible Asset Page** - A page for the public to mint Fungible Assets.
- **Create Fungible Asset page** - A page for creating new asset. This page is not accessible on production.
- **My Fungible Assets page** - A page to view all the assets created under the current Move module (smart contract). This page is not accessible on production.

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
