import { ABI } from "@/utils/abi";
import { aptosClient } from "@/utils/aptos";
import { useEffect, useState } from "react";

export const useGetRegistry = () => {
  const [registry, setRegistry] = useState<string[]>();
  useEffect(() => {
    aptosClient
      .view({
        payload: {
          function: `${ABI.address}::launchpad::get_registry`,
          typeArguments: [],
          functionArguments: [],
        },
      })
      .then((res) => {
        setRegistry(res[0] as string[]);
      });
  }, []);
  return registry;
};
