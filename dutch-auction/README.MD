# Dutch Auction

## Overview

This smart contract enables the sale of NFTs for fungible Assets utilizing Dutch Auction principles

## Aptos Specific Things

In this example, we use the Digital Assets standard `Object<Token>` for representing each individual token

## Solidity Specific Things

The DutchAuction contract inherits from the Ownable and ERC721 contracts, allowing for the implementation of the ownership logic and seamless integration of the NFT functionallity.