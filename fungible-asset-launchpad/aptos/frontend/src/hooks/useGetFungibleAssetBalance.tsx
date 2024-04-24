import { surfClient } from "@/utils/aptos";
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
    surfClient.view
      .get_balance({
        typeArguments: [],
        functionArguments: [
          fungibleAssetAddress as `0x${string}`,
          walletAddress as `0x${string}`,
        ],
      })
      .then((res) => {
        setBalance(res[0] as string);
      });
  }, [fungibleAssetAddress, walletAddress]);
  return balance;
};
