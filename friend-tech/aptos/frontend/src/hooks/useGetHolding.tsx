import { surfClient } from "@/utils/aptos";
import { useEffect, useState } from "react";

export const useGetHolding = (
  issuerAddress: `0x${string}`,
  walletAddress?: `0x${string}`
) => {
  const [balance, setBalance] = useState<string>();
  useEffect(() => {
    if (!walletAddress) {
      return;
    }
    surfClient.view
      .get_holding_obj_addr({
        typeArguments: [],
        functionArguments: [issuerAddress, walletAddress],
      })
      .then(async (res) => {
        const holdingObject = res[0];
        const holding = await surfClient.view
          .get_holding({
            typeArguments: [],
            functionArguments: [holdingObject],
          })
          .catch((e) => {
            console.error("error getting holding obj", e);
            return ["0", "0", "0"];
          });
        setBalance(holding[2]);
      })
      .catch((e) => {
        console.error("error getting holding obj addr", e);
        setBalance("0");
      });
  }, [issuerAddress, walletAddress]);
  return balance;
};
