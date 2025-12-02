import { AccountAddress, GetFungibleAssetMetadataResponse } from "@aptos-labs/ts-sdk";
import { useState, useEffect, useRef } from "react";
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
  const [isLoading, setIsLoading] = useState(true);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const assetObjectsRef = useRef<Array<{ inner: string }>>([]);
  const maxRetriesRef = useRef(0);
  const MAX_RETRIES = 15; // Poll for up to 5 minutes (60 * 5 seconds)

  useEffect(() => {
    let isMounted = true;

    const fetchMetadata = async () => {
      try {
        // Fetch the contract registry address
        const faObjects = await getRegistry();
        assetObjectsRef.current = faObjects;

        // Initial fetch
        await pollForMetadata(faObjects, isMounted);

        // Set up polling for missing metadata
        if (isMounted) {
          intervalRef.current = setInterval(async () => {
            await pollForMetadata(assetObjectsRef.current, isMounted);
          }, 5000); // Poll every 5 seconds
        }
      } catch (error) {
        console.error("Error fetching asset metadata:", error);
        if (isMounted) {
          setIsLoading(false);
        }
      }
    };

    fetchMetadata();

    return () => {
      isMounted = false;
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, []);

  const pollForMetadata = async (
    objects: Array<{ inner: string }>,
    isMounted: boolean,
  ) => {
    if (!isMounted) return;

    const metadatas = await Promise.all(
      objects.map(async (object: { inner: string }) => {
        const formattedObjectAddress = AccountAddress.from(object.inner).toString();

        try {
          const metadata = await aptosClient().getFungibleAssetMetadata({
            options: {
              where: { asset_type: { _eq: `${formattedObjectAddress}` } },
            },
          });
          return metadata[0];
        } catch (error) {
          console.error(`Error fetching metadata for ${formattedObjectAddress}:`, error);
          return undefined;
        }
      }),
    );

    if (!isMounted) return;

    // Check if all assets have metadata
    const allIndexed = metadatas.every((metadata) => metadata !== undefined);
    const validMetadatas = metadatas.filter(
      (metadata): metadata is NonNullable<typeof metadata> => metadata !== undefined,
    );

    setFAs(validMetadatas);

    // Stop polling if all assets are indexed or max retries reached
    if (allIndexed) {
      setIsLoading(false);
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
    } else {
      maxRetriesRef.current += 1;
      if (maxRetriesRef.current >= MAX_RETRIES) {
        console.warn("Max retries reached. Some assets may not be indexed yet.");
        setIsLoading(false);
        if (intervalRef.current) {
          clearInterval(intervalRef.current);
          intervalRef.current = null;
        }
      }
    }
  };

  return { fas, isLoading };
}

const getRegistry = async () => {
  const registry = await aptosClient().view<[[{ inner: string }]]>({
    payload: {
      function: `${AccountAddress.from(import.meta.env.VITE_MODULE_ADDRESS)}::launchpad::get_registry`,
    },
  });
  return registry[0];
};
