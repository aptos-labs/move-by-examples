import { InputTransactionData } from "@aptos-labs/wallet-adapter-react";
// Internal utils
import { convertAmountFromHumanReadableToOnChain } from "@/utils/helpers";

export type MintAssetArguments = {
  assetType: string;
  amount: number;
  decimals: number;
};

export const mintAsset = (args: MintAssetArguments): InputTransactionData => {
  const { assetType, amount, decimals } = args;
  return {
    data: {
      function: `${import.meta.env.VITE_MODULE_ADDRESS}::launchpad::mint_fa`,
      typeArguments: [],
      functionArguments: [assetType, convertAmountFromHumanReadableToOnChain(amount, decimals)],
    },
  };
};
