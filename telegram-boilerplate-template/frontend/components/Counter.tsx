import { useEffect, useState } from "react";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { useWalletClient } from "@thalalabs/surf/hooks";
import { useQuery, useQueryClient } from "@tanstack/react-query";

// Internal components
import { aptosClient, surfClient } from "@/utils/aptosClient";
import { Button } from "@/components/ui/button";
import { toast } from "@/components/ui/use-toast";
import { ABI } from "@/utils/abi";

export function Counter() {
  const [counter, setCounter] = useState<number>(0);
  const { account } = useWallet();
  const { client: walletClient } = useWalletClient();
  const queryClient = useQueryClient();

  const { data } = useQuery({
    queryKey: ["counter", account?.address],
    refetchInterval: 10_000,
    queryFn: async () => {
      try {
        const counter = await surfClient()
          .view.count({
            typeArguments: [],
            functionArguments: [account?.address as `0x${string}`],
          })
          .then((result) => {
            return parseInt(result[0]);
          });

        return {
          counter,
        };
      } catch (error: any) {
        toast({
          variant: "destructive",
          title: "Error",
          description: error,
        });
        return {
          counter: 0,
        };
      }
    },
  });

  const onClickButton = async () => {
    if (!account || !walletClient) {
      console.error("Account or wallet client not available");
      return;
    }

    try {
      const committedTransaction = await walletClient.useABI(ABI).click({
        type_arguments: [],
        arguments: [],
      });
      const executedTransaction = await aptosClient().waitForTransaction({
        transactionHash: committedTransaction.hash,
      });
      queryClient.invalidateQueries();
      toast({
        title: "Success",
        description: `Transaction succeeded, hash: ${executedTransaction.hash}`,
      });
    } catch (error) {
      console.error(error);
    }
  };

  useEffect(() => {
    if (data) {
      setCounter(data.counter);
    }
  }, [data]);

  return (
    <div className="flex flex-col gap-6">
      <h4 className="text-lg font-medium">Counter {counter}</h4>
      <Button onClick={onClickButton}>Increment counter</Button>
    </div>
  );
}
