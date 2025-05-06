# Taxed Fungible Asset

## Overview

When the contract is deployed, it will create a new fungible asset and mint the whole supply to the deployer. Let's name the fungible asset TFA aka taxed fungible asset.

Then deployer can use the script to create a TFA-APT 50:50 weighted pool on Thala. This pool now has all the TFA supply in it.

Now if anyone swaps APT to TFA using the Thala pool, TFA creator gets a 5% tax, i.e. if 1 APT can swap to 100 TFA, user ends up getting 95 TFA and creator gets 5TFA.

TFA Transfer between users is not taxed.

If anyone swaps TFA to APT using the Thala pool, TFA creator gets a 5% tax, i.e. if 100 TFA can swap to 1 APT, user ends up getting less than 1 APT and creator gets 5TFA.

## Aptos Specific Things

We make use of the Dispatchable Fungible Assets, which is built on top of the Fungible Asset standard. 
Refer to the section in the [Fungible Asset docs](https://preview.aptos.dev/en/build/smart-contracts/fungible-asset#dispatchable-fungible-asset-advanced) for more information. 
