## Telegram boilerplate template

This template is a minimal Telegram mini app that uses [Mizu wallet](https://mizu.io/) to interact with a simple Aptos contract on testnet.

You can access the mini app by starting a chat with the example bot at https://t.me/Djdhdfh_bot.

To deploy your own mini app, you need to create a bot, deploy the mini app to say vercel just like deploying a normal web app, link the web app to the bot. You can follow a complete guide on the [mini app doc](https://docs.telegram-mini-apps.com/platform/creating-new-app).

## Create Aptos Dapp Boilerplate Template

The Boilerplate template provides a starter dapp with all necessary dapp infrastructure and a simple wallet info implementation.

## The Boilerplate template provides:

- **Folder structure** - A pre-made dapp folder structure with a `frontend` and `move` folders.
- **Dapp infrastructure** - All required dependencies a dapp needs to start building on the Aptos network.
- **Wallet Info implementation** - Pre-made `WalletInfo` components to demonstrate how one can use to read a connected Wallet info.

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
- `npm run move:test` - a command to run Move unit tests
- `npm run move:compile` - a command to compile the Move contract
- `npm run deploy` - a command to deploy the dapp to Vercel

For all other available CLI commands, can run `npx aptos` and see a list of all available commands.
