"use client";

import { useGetFungibleAssetBalance } from "@/hooks/useGetFungibleAssetBalance";
import { humanReadableToOnChain, onChainToHumanReadable } from "@/utils/math";
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
  decimals: number;
};

export const MintFungibleAsset = ({
  fungibleAssetAddress,
  decimals,
}: Props) => {
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
        functionArguments: [
          fungibleAssetAddress,
          humanReadableToOnChain(parseFloat(mintAmount), decimals),
        ],
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
      <Stack divider={<StackDivider />} spacing="4" textAlign="center">
        <Box>
          <Heading size="xs">Balance</Heading>
          <Text pt="2" fontSize="sm">
            {onChainToHumanReadable(parseInt(balance), decimals)}
          </Text>
        </Box>
        <Flex>
          <Button onClick={onMint}>Mint</Button>
          <NumberInput
            precision={decimals}
            step={1 / Math.pow(10, decimals)}
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
