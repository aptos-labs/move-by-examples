import { useWalletClient } from "@thalalabs/surf/hooks";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { ABI } from "@repo/contract-abis/src/message_board_abi";

import { aptosClient, isSendableNetwork } from "@/utils/aptos";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useToast } from "@/components/ui/use-toast";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";

const FormSchema = z.object({
  stringContent: z.string().min(2),
  numberContent: z.number().int(),
  addressContent: z.string(),
  optionalStringContent: z.string().optional(),
  optionalNumberContent: z.number().int().optional(),
  optionalAddressContent: z.string().optional(),
});

export function PostMessageWithSurf() {
  const { toast } = useToast();
  const { connected, account, network, wallet } = useWallet();
  const { client: walletClient } = useWalletClient();

  let sendable = isSendableNetwork(connected, network?.name);

  const form = useForm<z.infer<typeof FormSchema>>({
    resolver: zodResolver(FormSchema),
    defaultValues: {
      stringContent: "",
      numberContent: 0,
      addressContent: "0x1",
      optionalStringContent: undefined,
      optionalNumberContent: undefined,
      optionalAddressContent: undefined,
    },
  });

  const onSignAndSubmitTransaction = async (
    data: z.infer<typeof FormSchema>
  ) => {
    if (!account || !walletClient) {
      console.error("Account or wallet client not available");
      return;
    }

    try {
      const committedTransaction = await walletClient
        ?.useABI(ABI)
        .post_message({
          type_arguments: [],
          arguments: [
            // "Hello World!",
            data.username,
            123,
            account.address as `0x${string}`,
            // passing null will trigger error at this line: https://github.com/ThalaLabs/surf/blob/3815bcf024438026f7dce87cd4971f3698768374/src/core/WalletClient.ts#L32
            // passing undefine works, but i got warning on VSCode as Surf expects `null` instead of `undefined` for option::none()
            undefined as any,
            undefined as any,
            undefined as any,
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
        <Form {...form}>
          <form
            onSubmit={form.handleSubmit(onSignAndSubmitTransaction)}
            className="w-2/3 space-y-6"
          >
            <FormField
              control={form.control}
              name="username"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Username</FormLabel>
                  <FormControl>
                    <Input placeholder="shadcn" {...field} />
                  </FormControl>
                  <FormDescription>
                    This is your public display name.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <Button type="submit"> disabled={!sendable}Post</Button>
          </form>
        </Form>
      </CardContent>
    </Card>
  );
}
