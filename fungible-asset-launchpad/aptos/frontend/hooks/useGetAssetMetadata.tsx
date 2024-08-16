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
    getRegistry().then((registry) => {
      // fetch fungible assets objects created under that contract registry address
      getObjects(registry).then((objects) => {
        // get each fungible asset object metadata
        getMetadata(objects).then((metadatas) => {
          setFAs(metadatas);
        });
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

const getObjects = async (registry: [{ inner: string }]) => {
  const objects = await Promise.all(
    registry.map(async (register: { inner: string }) => {
      const formattedRegistry = AccountAddress.from(register.inner).toString();
      const object = await aptosClient().getObjectDataByObjectAddress({
        objectAddress: formattedRegistry,
      });

      return object.owner_address;
    }),
  );
  return objects;
};

const getMetadata = async (objects: Array<string>) => {
  const metadatas = await Promise.all(
    objects.map(async (object: string) => {
      const formattedObjectAddress = AccountAddress.from(object).toString();

      const metadata = await aptosClient().getFungibleAssetMetadata({
        options: {
          where: { creator_address: { _eq: `${formattedObjectAddress}` } },
        },
      });
      return metadata[0];
    }),
  );
  return metadatas;
};
