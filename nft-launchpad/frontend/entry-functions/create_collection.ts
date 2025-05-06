import { AccountAddressInput } from "@aptos-labs/ts-sdk";
import { InputTransactionData } from "@aptos-labs/wallet-adapter-react";

import { APT_DECIMALS, dateToSeconds, convertAmountFromHumanReadableToOnChain } from "@/utils/helpers";

export type CreateCollectionArguments = {
  collectionDescription: string; // The collection description
  collectionName: string; // The collection name
  projectUri: string; // The project URI (i.e https://mydomain.com)
  maxSupply: number; // The amount of NFTs in a collection
  royaltyPercentage?: number; // The percentage of trading value that collection creator gets when an NFT is sold on marketplaces
  preMintAmount?: number; // amount of NFT to pre-mint for myself
  allowList?: Array<AccountAddressInput>; // addresses in the allow list
  allowListStartDate?: Date; // allow list start time (in seconds)
  allowListEndDate?: Date; // allow list end time (in seconds)
  allowListLimitPerAccount?: number; // mint limit per address in the allow list
  allowListFeePerNFT?: number; // mint fee per NFT for the allow list
  publicMintStartDate?: Date; // public mint start time (in seconds)
  publicMintEndDate?: Date; // public mint end time (in seconds)
  publicMintLimitPerAccount: number; // mint limit per address in the public mint
  publicMintFeePerNFT?: number; // mint fee per NFT for the public mint, on chain stored in smallest unit of APT (i.e. 1e8 oAPT = 1 APT)
};

export const createCollection = (args: CreateCollectionArguments): InputTransactionData => {
  const {
    collectionDescription,
    collectionName,
    projectUri,
    maxSupply,
    royaltyPercentage,
    preMintAmount,
    allowList,
    allowListStartDate,
    allowListEndDate,
    allowListLimitPerAccount,
    allowListFeePerNFT,
    publicMintStartDate,
    publicMintEndDate,
    publicMintLimitPerAccount,
    publicMintFeePerNFT,
  } = args;
  return {
    data: {
      function: `${import.meta.env.VITE_MODULE_ADDRESS}::launchpad::create_collection`,
      typeArguments: [],
      functionArguments: [
        collectionDescription,
        collectionName,
        projectUri,
        maxSupply,
        royaltyPercentage,
        preMintAmount,
        allowList,
        dateToSeconds(allowListStartDate),
        dateToSeconds(allowListEndDate),
        allowListLimitPerAccount,
        allowListFeePerNFT,
        publicMintStartDate ? dateToSeconds(publicMintStartDate) : dateToSeconds(new Date()),
        dateToSeconds(publicMintEndDate),
        publicMintLimitPerAccount,
        publicMintFeePerNFT ? convertAmountFromHumanReadableToOnChain(publicMintFeePerNFT, APT_DECIMALS) : 0,
      ],
    },
  };
};
