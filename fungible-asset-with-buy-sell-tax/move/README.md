# Fungible Asset with buy / sell tax

Detailed guide on Aptos Learn: https://learn.aptoslabs.com/en/code-examples/dispatchable-fa

Video guide in English: https://www.youtube.com/watch?v=sIS7AnL9DL4

Video guide in Chinese: https://www.youtube.com/watch?v=NKOVDmKXuVM

## Overview

This example demonstrates a few things

- How to implement a fungible asset with buy/sell tax using dispatchable fungible asset standard
- How to do cross contract calls (we call thala contract to create pool for the TFA and to swap)

We have 5 subdirectories

- `FungibleAssetWithBuySellTax`: The main contract that implements the fungible asset with buy/sell tax, when it's deployed, it will create a new fungible asset with transfer hook.
- `ThalaV2Interface`: The contract to mock thala v2 interface, because we need to know what the interface looks like to call it.
- `ThalaV2RouterInterface`: The contract to mock thala v2 router interface, because we need to know what the interface looks like to call it.
- `HyperionInterface`: The contract to mock hyperion interface, because we need to know what the interface looks like to call it.
- `ScriptsOnly`: Some Move scripts to
  - Create the TFA-APT pool on thala or hyperion with initial liquidity.
  - Register the pool in the fungible asset contract.
  - Swap TFA to APT from the pool.

## Deploy your own version with Thala or Hyperion

This whole example is built on Thala mainnet contract so you need some mainnet APT to test it out.

1. Deploy the `FungibleAssetWithBuySellTax` contract.
   - In `FungibleAssetWithBuySellTax`, run `./sh_scripts/init.sh` to create a new Aptos account, run `./sh_scripts/deploy.sh` to deploy the contract. This will create the TFA token and mint the whole supply to the deployer account.
2. Create the TFA-APT pool on Thala with initial liquidity.
   - In `ScriptsOnly`, replace the FA address in `scripts/create_thala_pool.move` with your FA address, you can look it up on explorer.
   - Run `./sh_scripts/create_thala_pool.sh` to create the pool and add initial liquidity.
3. Register the thala pool in the fungible asset contract.
   - In `ScriptsOnly`, replace the pool address in `scripts/register_pool.move` with your pool address, you can look it up on explorer.
   - Run `./sh_scripts/run_register_pool.sh` to register the pool in the fungible asset contract.
4. Swap TFA to APT from the thala pool.
   - In `ScriptsOnly`, replace the pool address and FA address in `scripts/swap_from_router.move` with your own.
   - Run `./sh_scripts/run_swap_from_thala_router.sh` to swap TFA to APT from the thala pool.
   - In the explorer, you should see there's `SellTaxCollectedEvent` emitted from the fungible asset contract, and some TFA should be sent to the deployer account as tax.

## Integrating with other Dex on Aptos

You can create pools on other DEXes and register the pool in the fungible asset contract. The contract tracks a list of pools, when there's transfer in and out from the pool, it knows it's a buy/sell tx and will collect the tax.

## Compare to other chains

We make use of the Dispatchable Fungible Assets, which is built on top of the Fungible Asset standard.
Refer to the section in the [Fungible Asset docs](https://preview.aptos.dev/en/build/smart-contracts/fungible-asset#dispatchable-fungible-asset-advanced) for more information.

If you come from EVM, you usually implement the buy sell tax in your own ERC-20 contract. If you come from Solana, Aptos might feel a bit similar because we also use static dispatch, our dispatchable fungible asset essentially lets you register a transfer hook to be invoked when a transfer is made, similar to the token extension in Solana.
