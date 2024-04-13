# Todo List Contract on Aptos

There are 2 versions

- simple todo list: each user can only have one todo list, stored directly under the user's account
- advanced todo list: each user can have multiple todo lists, each todo list is stored under an object owned by the user, this is similar to PDA on Solana

## Env setup

Check out the guide from [Aptos Learn](https://learn.aptoslabs.com/example/aptogotchi-beginner/env-setup).

## Play with testnet deployments on explorer

Simple version is deployed [here](https://explorer.aptoslabs.com/object/0xdeb9fd0a4ca01e848f978ee5191595d7ee859c450b5e51629f04dec9b7560e60/modules/code/simple_todo_list?network=testnet).

Advanced version is deployed [here](https://explorer.aptoslabs.com/object/0x65ab5f8c243471af66967b1780e6e1d7710cb7b676545dac5652a2fbed0143fb/modules/code/advanced_todo_list?network=testnet).
