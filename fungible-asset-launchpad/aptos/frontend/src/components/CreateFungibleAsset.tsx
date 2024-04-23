"use client";

import { ABI } from "@/utils/abi";
import { aptosClient } from "@/utils/aptos";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Box, Button, FormControl, FormLabel, Input } from "@chakra-ui/react";
import { useState } from "react";

export const CreateFungibleAsset = () => {
  const [maxSupply, setMaxSupply] = useState("1000");
  const [fungibleAssetName, setFungibleAssetName] = useState("Test FA");
  const [symbol, setSymbol] = useState("TFA");
  const [decimals, setDecimals] = useState("2");
  const [iconUri, setIconUri] = useState(
    "https://otjbxblyfunmfblzdegw.supabase.co/storage/v1/object/public/aptogotchi/food.png"
  );
  const [projectUri, setProjectUri] = useState(
    "https://github.com/aptos-labs/solana-to-aptos/tree/main/aptos/launchpad"
  );

  const { account, signAndSubmitTransaction } = useWallet();

  const onCreate = async () => {
    if (!account) {
      throw new Error("Wallet not connected");
    }
    if (
      !maxSupply ||
      !fungibleAssetName ||
      !symbol ||
      !decimals ||
      !iconUri ||
      !projectUri
    ) {
      throw new Error("Invalid input");
    }
    const response = await signAndSubmitTransaction({
      sender: account.address,
      data: {
        function: `${ABI.address}::launchpad::create_fa`,
        typeArguments: [],
        functionArguments: [
          maxSupply,
          fungibleAssetName,
          symbol,
          decimals,
          iconUri,
          projectUri,
        ],
      },
    });
    await aptosClient.waitForTransaction({
      transactionHash: response.hash,
    });
  };

  return (
    account && (
      <Box>
        <FormControl>
          <FormLabel>Max Supply</FormLabel>
          <Input
            type="number"
            onChange={(e) => setMaxSupply(e.target.value)}
            value={maxSupply}
          />
          <FormLabel>Fungible Asset Name</FormLabel>
          <Input
            type="text"
            onChange={(e) => setFungibleAssetName(e.target.value)}
            value={fungibleAssetName}
          />
          <FormLabel>Symbol</FormLabel>
          <Input
            type="text"
            onChange={(e) => setSymbol(e.target.value)}
            value={symbol}
          />
          <FormLabel>Decimal</FormLabel>
          <Input
            type="number"
            onChange={(e) => setDecimals(e.target.value)}
            value={decimals}
          />
          <FormLabel>Icon URI</FormLabel>
          <Input
            type="url"
            onChange={(e) => setIconUri(e.target.value)}
            value={iconUri}
          />
          <FormLabel>Project URI</FormLabel>
          <Input
            type="url"
            onChange={(e) => setProjectUri(e.target.value)}
            value={projectUri}
          />
        </FormControl>
        <Button onClick={onCreate}>Create</Button>
      </Box>
    )
  );
};
