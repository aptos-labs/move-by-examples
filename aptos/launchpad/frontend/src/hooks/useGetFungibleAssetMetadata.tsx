import { ABI } from "@/utils/abi";
import { aptosClient } from "@/utils/aptos";
import { FungibleAssetMetadata } from "@/utils/types";
import { useEffect, useState } from "react";

export const useGetFungibleAssetMetadata = (address: string) => {
  const [fungibleAsset, setFungibleAsset] = useState<FungibleAssetMetadata>();
  useEffect(() => {
    aptosClient
      .view({
        payload: {
          function: `${ABI.address}::launchpad::get_metadata`,
          typeArguments: [],
          functionArguments: [address],
        },
      })
      .then((res) => {
        setFungibleAsset({
          name: res[0] as string,
          symbol: res[1] as string,
          decimals: res[2] as number,
        });
      });
  }, [address]);
  return fungibleAsset;
};
