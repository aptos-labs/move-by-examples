# Todo List Contract on Aptos

There are 2 versions

- simple todo list: each user can only have one todo list, stored directly under the user's account
- advanced todo list: each user can have multiple todo lists, each todo list is stored under an object owned by the user, this is similar to PDA on Solana

## Env setup

Check out the guide from [Aptos Learn](https://learn.aptoslabs.com/example/aptogotchi-beginner/env-setup).

## Play with testnet deployments on explorer

Go to testnet explorer [here](https://explorer.aptoslabs.com/?network=testnet) and search for the contract address. 

You can find the contract address in each contract directory's `contract_address.txt`.

On explorer, you can read the contract code, call entry functions (need to connect wallet), and call view functions.
