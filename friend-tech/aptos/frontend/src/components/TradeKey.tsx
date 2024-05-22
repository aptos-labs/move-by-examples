"use client";

import { ABI } from "@/utils/abi";
import { aptosClient } from "@/utils/aptos";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import {
  Heading,
  Box,
  VStack,
  StackDivider,
  Text,
  NumberInput,
  NumberInputField,
  NumberInputStepper,
  NumberIncrementStepper,
  NumberDecrementStepper,
  Button,
  HStack,
} from "@chakra-ui/react";
import { useState } from "react";
import { useGetHolding } from "@/hooks/useGetHolding";
import { useRouter } from "next/navigation";

type Props = {
  issuerInfo: {
    issuerAddress: `0x${string}`;
    username: string;
    totalIssuedShares: number;
    holderHoldingObjects: `0x${string}`[];
  };
};

export const TradeKey = ({ issuerInfo }: Props) => {
  const [tradeAmount, setTradeAmount] = useState(1);
  const { account, signAndSubmitTransaction } = useWallet();
  const router = useRouter();
  const balance = useGetHolding(
    issuerInfo.issuerAddress,
    account?.address as `0x${string}`
  );

  const onTrade = async (action: "buy" | "sell") => {
    if (!account) {
      throw new Error("Wallet not connected");
    }
    const response = await signAndSubmitTransaction({
      sender: account.address,
      data: {
        function: `${ABI.address}::friend_tech::${action}_key`,
        typeArguments: [],
        functionArguments: [issuerInfo.issuerAddress, tradeAmount],
      },
    });
    await aptosClient
      .waitForTransaction({
        transactionHash: response.hash,
      })
      .then((resp) => {
        console.log("Traded Key, TX hash", resp.hash);
        router.refresh();
      });
  };

  if (!account) {
    return <Box>Connecting Wallet</Box>;
  }

  return (
    balance && (
      <VStack divider={<StackDivider />} spacing="4" textAlign="center">
        <Box>
          <Heading size="xs">My Balance</Heading>
          <Text pt="2" fontSize="sm">
            {balance}
          </Text>
        </Box>
        <NumberInput
          step={1}
          onChange={(value) => {
            setTradeAmount(parseInt(value));
          }}
          value={tradeAmount}
        >
          <NumberInputField />
          <NumberInputStepper>
            <NumberIncrementStepper />
            <NumberDecrementStepper />
          </NumberInputStepper>
        </NumberInput>
        <HStack>
          <Button onClick={() => onTrade("buy")}>Buy Key</Button>
          <Button onClick={() => onTrade("sell")}>Sell Key</Button>
        </HStack>
      </VStack>
    )
  );
};
