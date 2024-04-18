# Solana to Aptos Guide

This repo contains a side by side comparison of a series of contracts implemented in Move for Aptos and Rust (Anchor) for Solana. The purpose of this repo is to help Solana developers interesting in Aptos to get started with codes and concepts they are already familiar with.

We also have step by step tutorials for these examples on [Aptos Learn](https://learn.aptoslabs.com/examples), just search for Solana on the page.

There are 3 contracts so far

- simple todo list: anyone can create todo list, create todo and complete todo.
- advanced todo list: difference from simple todo list user can own multiple todo list contract.
- token launchpad: anyone can create new token, discover tokens created by others and mint them.

So far we covered topics like

- Create single contract app.
- Define custom data structures.
- Define read and write endpoints for your contract.
- Emit event.
- Create token.
- Cross contract call.
- Write unit test.
- Deploy contract to testnet.
- Create Move script to atomically calling multiple functions.
- Interact with the contract using TypeScript SDK.

See both subdirectories' readmes for more details.
