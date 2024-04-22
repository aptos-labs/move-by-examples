import { ABI } from "@/utils/abi";
import { aptosClient } from "@/utils/aptos";
import { useEffect, useState } from "react";

export const useGetFungibleAssetBalance = (
  fungibleAssetAddress: string,
  walletAddress?: string
) => {
  const [balance, setBalance] = useState<string>();
  useEffect(() => {
    if (!walletAddress) {
      return;
    }
    aptosClient
      .view({
        payload: {
          function: `${ABI.address}::launchpad::get_balance`,
          typeArguments: [],
          functionArguments: [fungibleAssetAddress, walletAddress],
        },
      })
      .then((res) => {
        setBalance(res[0] as string);
      });
  }, [fungibleAssetAddress, walletAddress]);
  return balance;
};
