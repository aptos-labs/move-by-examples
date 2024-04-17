"use client";

import { useGetFungibleAssetBalance } from "@/hooks/useGetFungibleAssetBalance";
import { ABI } from "@/utils/abi";
import { aptosClient } from "@/utils/aptos";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import {
  Heading,
  Box,
  Stack,
  StackDivider,
  Text,
  NumberInput,
  NumberInputField,
  NumberInputStepper,
  NumberIncrementStepper,
  NumberDecrementStepper,
  Button,
  Flex,
} from "@chakra-ui/react";
import { useState } from "react";

type Props = {
  fungibleAssetAddress: string;
};

export const MintFungibleAsset = ({ fungibleAssetAddress }: Props) => {
  const [mintAmount, setMintAmount] = useState("1");
  const { account, signAndSubmitTransaction } = useWallet();
  const balance = useGetFungibleAssetBalance(
    fungibleAssetAddress,
    account?.address
  );

  const onMint = async () => {
    if (!account) {
      throw new Error("Wallet not connected");
    }
    const response = await signAndSubmitTransaction({
      sender: account.address,
      data: {
        function: `${ABI.address}::launchpad::mint_fa`,
        typeArguments: [],
        functionArguments: [fungibleAssetAddress, mintAmount],
      },
    });
    await aptosClient
      .waitForTransaction({
        transactionHash: response.hash,
      })
      .then((resp) => {
        console.log("Minted FA, TX hash", resp.hash);
      });
  };

  return (
    account &&
    balance && (
      <Stack divider={<StackDivider />} spacing="4">
        <Box>
          <Heading size="xs" textTransform="uppercase">
            Balance
          </Heading>
          <Text pt="2" fontSize="sm">
            {balance}
          </Text>
        </Box>
        <Flex>
          <Button onClick={onMint}>Mint</Button>
          <NumberInput
            onChange={(value) => {
              setMintAmount(value);
            }}
            value={mintAmount}
          >
            <NumberInputField />
            <NumberInputStepper>
              <NumberIncrementStepper />
              <NumberDecrementStepper />
            </NumberInputStepper>
          </NumberInput>
        </Flex>
      </Stack>
    )
  );
};
