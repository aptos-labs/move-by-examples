import { InputTransactionData } from "@aptos-labs/wallet-adapter-react";

export type MintNftArguments = {
  collectionId: string;
  amount: number;
};

export const mintNFT = (args: MintNftArguments): InputTransactionData => {
  const { collectionId, amount } = args;
  return {
    data: {
      function: `${import.meta.env.VITE_MODULE_ADDRESS}::launchpad::mint_nft`,
      typeArguments: [],
      functionArguments: [collectionId, amount],
    },
  };
};
