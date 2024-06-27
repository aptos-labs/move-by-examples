# What is this?
**Simple Multidex Router** is a showcase of how to interact with external third party dependencies. In this case, Liquidswap and PancakeSwap.

Useful for seeing examples of:
* Third party dependencies
* Scripts for e2e tests against live smart contracts (w/ relevant state) on testnet
* Multi-dex router foundation
* Gas simulations
* Creating Coins

# Primary file
* `sources/multidex_router.move` - showcase of chaining two external, third party function calls into a single, atomic entry function

# Why test using Scripts and simulations?
Simulations against the live state of third party dependencies are invaluable when testing smart contracts. 
Even if one were to redeploy the smart contracts onto a local network, the data and state of it won't be accurate to the final outcome.

`aptos move test` does not target a specific chain or existing state, but Scripts can be repurposed to perform these live data simulations.

## Relevant test files
* `scripts/dex_routing_e2e.move` - simulate against on-chain state
* `sources/artificial_coins.move` - deploy temporary tokens for performing swaps during testing

# Environment
Setup currently targets **testnet**.

*Can be tested on Mainnet by using simulations, if Artificial Coins are replaced by already-supported Coins on both Liquidswap and PancakeSwap.*

# How to run
Aptos init to **testnet**.

Deploy modules.
```console
    aptos move publish --profile default --named-addresses simple_multidex_router_addr={YOUR_RESULTING_ADDRESS_APTOS_INIT} --assume-yes
```
Compile and Run script with simulation.
```console
    aptos move compile-script --named-addresses simple_multidex_router_addr={YOUR_RESULTING_ADDRESS_APTOS_INIT} && \ 
    aptos move run-script --compiled-script-path ./script.mv --profile default --profile-gas
```

To do a full deployment + test:
```console
    aptos move publish --named-addresses simple_multidex_router_addr={YOUR_RESULTING_ADDRESS_APTOS_INIT} --assume-yes && \
    aptos move compile-script --named-addresses simple_multidex_router_addr={YOUR_RESULTING_ADDRESS_APTOS_INIT} && \
    aptos move run-script --compiled-script-path ./script.mv --profile default --profile-gas --assume-yes
```