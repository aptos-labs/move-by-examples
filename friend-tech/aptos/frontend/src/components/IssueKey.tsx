"use client";

import { ABI } from "@/utils/abi";
import { aptosClient } from "@/utils/aptos";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import {
  Box,
  Button,
  FormControl,
  FormLabel,
  Heading,
  Input,
} from "@chakra-ui/react";
import { useState } from "react";

export const IssueKey = () => {
  const [username, setUsername] = useState("Move Friend 123");
  const { account, signAndSubmitTransaction } = useWallet();

  const onIssueKey = async () => {
    if (!account) {
      throw new Error("Wallet not connected");
    }
    const response = await signAndSubmitTransaction({
      sender: account.address,
      data: {
        function: `${ABI.address}::friend_tech::issue_key`,
        typeArguments: [],
        functionArguments: [username],
      },
    });
    await aptosClient
      .waitForTransaction({
        transactionHash: response.hash,
      })
      .then((resp) => {
        console.log("Issued Key, TX hash", resp.hash);
      });
  };

  if (!account) {
    return <Box>Connecting Wallet</Box>;
  }

  return (
    <Box>
      <Heading size="md">Issue Key</Heading>
      <FormControl>
        <FormLabel>Username</FormLabel>
        <Input
          type="text"
          onChange={(e) => setUsername(e.target.value)}
          value={username}
        />
      </FormControl>
      <Button onClick={onIssueKey}>Issue Key</Button>
    </Box>
  );
};
