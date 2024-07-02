import { aptosClient, isSendableNetwork } from "@/utils/aptos";
import { useWalletClient } from "@thalalabs/surf/hooks";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Button } from "../ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "../ui/card";
import { useToast } from "../ui/use-toast";
import { ABI } from "@repo/contract-abis/src/message_board_abi";

export function PostMessageWithSurf() {
  const { toast } = useToast();
  const { connected, account, network, wallet } = useWallet();
  const { client: walletClient } = useWalletClient();

  let sendable = isSendableNetwork(connected, network?.name);

  const onSignAndSubmitTransaction = async () => {
    if (!account || !walletClient) {
      console.error("Account or wallet client not available");
      return;
    }

    console.log("type of null", typeof null);
    try {
      const committedTransaction = await walletClient
        ?.useABI(ABI)
        .post_message({
          type_arguments: [],
          arguments: [
            "Hello World!",
            123,
            account.address as `0x${string}`,
            // passing null will trigger error at this line: https://github.com/ThalaLabs/surf/blob/3815bcf024438026f7dce87cd4971f3698768374/src/core/WalletClient.ts#L32
            // passing undefine works, but i got warning on VSCode as Surf expects `null` instead of `undefined` for option::none()
            null,
            null,
            null,
          ],
        });
      const executedTransaction = await aptosClient(network).waitForTransaction(
        {
          transactionHash: committedTransaction.hash,
        }
      );
      toast({
        title: "Success",
        description: `${wallet?.name ?? "Wallet"} transaction ${executedTransaction.hash} executed`,
      });
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Post a Message to Message Board</CardTitle>
      </CardHeader>
      <CardContent className="flex flex-wrap gap-4">
        <Button onClick={onSignAndSubmitTransaction} disabled={!sendable}>
          Post
        </Button>
      </CardContent>
    </Card>
  );
}
