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
  boolContent: z.boolean(),
  stringContent: z.string().min(2),
  numberContent: z.number().int(),
  addressContent: z.string().startsWith("0x"),
  objectContent: z.string().startsWith("0x"),
  vectorContent: z.array(z.string()),
  optionalBoolContent: z.boolean().optional(),
  optionalStringContent: z.string().optional(),
  optionalNumberContent: z.number().int().optional(),
  optionalAddressContent: z.string().startsWith("0x").optional(),
  optionalObjectContent: z.string().startsWith("0x").optional(),
  optionalVectorContent: z.array(z.string()).optional(),
});

export function PostMessageWithSurf() {
  const { toast } = useToast();
  const { connected, account, network, wallet } = useWallet();
  const { client: walletClient } = useWalletClient();

  let sendable = isSendableNetwork(connected, network?.name);

  const form = useForm<z.infer<typeof FormSchema>>({
    resolver: zodResolver(FormSchema),
    defaultValues: {
      boolContent: false,
      stringContent: "",
      numberContent: 0,
      addressContent: "0x1",
      objectContent: "",
      vectorContent: [],
      optionalBoolContent: undefined,
      optionalStringContent: undefined,
      optionalNumberContent: undefined,
      optionalAddressContent: undefined,
      optionalObjectContent: undefined,
      optionalVectorContent: undefined,
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
            data.boolContent,
            data.stringContent,
            data.numberContent,
            data.addressContent as `0x${string}`,
            data.objectContent as `0x${string}`,
            data.vectorContent,
            data.optionalBoolContent
              ? data.optionalBoolContent
              : (undefined as any),
            data.optionalStringContent
              ? data.optionalStringContent
              : (undefined as any),
            data.optionalNumberContent
              ? data.optionalNumberContent
              : (undefined as any),
            data.optionalAddressContent
              ? data.optionalAddressContent
              : (undefined as any),
            data.optionalObjectContent
              ? data.optionalObjectContent
              : (undefined as any),
            data.optionalVectorContent
              ? data.optionalVectorContent
              : (undefined as any),
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
              name="boolContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Bool Content</FormLabel>
                  <FormControl>
                    <Input type="checkbox" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store a bool content in the message on-chain
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="stringContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>String Content</FormLabel>
                  <FormControl>
                    <Input placeholder="shadcn" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store a string content in the message on-chain
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="numberContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Number Content</FormLabel>
                  <FormControl>
                    <Input type="number" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store a number content in the message on-chain
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="addressContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Address Content</FormLabel>
                  <FormControl>
                    <Input placeholder="0x1" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store an address content in the message on-chain
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="objectContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Object Content</FormLabel>
                  <FormControl>
                    <Input placeholder="0x1" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store an object content in the message on-chain
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="vectorContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Vector Content</FormLabel>
                  <FormControl>
                    <Input placeholder="0x1" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store a vector content in the message on-chain
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="optionalBoolContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Optional Bool Content</FormLabel>
                  <FormControl>
                    <Input type="checkbox" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store an optional bool content in the message on-chain
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="optionalStringContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Optional String Content</FormLabel>
                  <FormControl>
                    <Input placeholder="shadcn" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store an optional string content in the message on-chain
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="optionalNumberContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Optional Number Content</FormLabel>
                  <FormControl>
                    <Input type="number" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store an optional number content in the message on-chain
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="optionalAddressContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Optional Address Content</FormLabel>
                  <FormControl>
                    <Input placeholder="0x1" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store an optional address content in the message on-chain
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="optionalObjectContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Optional Object Content</FormLabel>
                  <FormControl>
                    <Input placeholder="0x1" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store an optional object content in the message on-chain
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="optionalVectorContent"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Optional Vector Content</FormLabel>
                  <FormControl>
                    <Input placeholder="0x1" {...field} />
                  </FormControl>
                  <FormDescription>
                    Store an optional vector content in the message on-chain
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
