import { AccountAddress, GetCollectionDataResponse } from "@aptos-labs/ts-sdk";
import { useState, useEffect } from "react";

import { aptosClient } from "@/utils/aptosClient";

/**
 * A react hook to get all collections under the current contract.
 *
 * This call can be pretty expensive when fetching a big number of collections,
 * therefore it is not recommended to use it in production
 *
 */
export function useGetCollections() {
  const [collections, setCollections] = useState<Array<GetCollectionDataResponse>>([]);

  useEffect(() => {
    async function run() {
      // fetch the contract registry address
      const registry = await getRegistry();
      // fetch collections objects created under that contract registry address
      const objects = await getObjects(registry);
      // get each collection object data
      const collections = await getCollections(objects);
      setCollections(collections);
    }

    run();
  }, []);

  return collections;
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

const getCollections = async (objects: Array<string>) => {
  const collections = await Promise.all(
    objects.map(async (object: string) => {
      const formattedObjectAddress = AccountAddress.from(object).toString();

      const collection = await aptosClient().getCollectionDataByCreatorAddress({
        creatorAddress: formattedObjectAddress,
      });

      return collection;
    }),
  );
  return collections;
};
