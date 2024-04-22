import { ABI } from "@/utils/abi";
import { aptosClient } from "@/utils/aptos";
import { useEffect, useState } from "react";

export const useGetFungibleAssetMaxSupply = (address: string) => {
  const [supply, setSupply] = useState<string>();
  useEffect(() => {
    aptosClient
      .view({
        payload: {
          function: `${ABI.address}::launchpad::get_max_supply`,
          typeArguments: [],
          functionArguments: [address],
        },
      })
      .then((res) => {
        setSupply(res[0] as string);
      });
  }, [address]);
  return supply;
};
