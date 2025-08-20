import { AccountAddress, GetFungibleAssetMetadataResponse } from "@aptos-labs/ts-sdk";
import { useState, useEffect } from "react";
// Internal utils
import { aptosClient } from "@/utils/aptosClient";

/**
 * A react hook to get fungible asset metadatas.
 *
 * This call can be pretty expensive when fetching a big number of assets,
 * therefore it is not recommended to use it in production
 *
 */
export function useGetAssetMetadata() {
  const [fas, setFAs] = useState<GetFungibleAssetMetadataResponse>([]);

  useEffect(() => {
    // fetch the contract registry address
    getRegistry().then((faObjects) => {
      // fetch fungible assets objects created under that contract registry address
      // get each fungible asset object metadata
      getMetadata(faObjects).then((metadatas) => {
        console.log("Fungible asset metadata:", metadatas);
        setFAs(metadatas);
      });
    });
  }, []);

  return fas;
}

const getRegistry = async () => {
  const registry = await aptosClient().view<[[{ inner: string }]]>({
    payload: {
      function: `${AccountAddress.from(import.meta.env.VITE_MODULE_ADDRESS)}::launchpad::get_registry`,
    },
  });
  return registry[0];
};

const getMetadata = async (
  objects: Array<{
    inner: string;
  }>,
) => {
  const metadatas = await Promise.all(
    objects.map(async (object: { inner: string }) => {
      const formattedObjectAddress = AccountAddress.from(object.inner).toString();

      const metadata = await aptosClient().getFungibleAssetMetadata({
        options: {
          where: { asset_type: { _eq: `${formattedObjectAddress}` } },
        },
      });
      return metadata[0];
    }),
  );
  return metadatas;
};
