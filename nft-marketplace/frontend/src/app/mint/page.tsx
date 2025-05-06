"use client";

import { Network, NetworkToChainId } from "@aptos-labs/ts-sdk";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import {
  Alert,
  AlertIcon,
  Box,
  Button,
  Flex,
  FormControl,
  FormLabel,
  Heading,
  Input,
} from "@chakra-ui/react";
import { useState } from "react";
import { APTOGOTCHI_CONTRACT_ADDRESS, aptos } from "@/utils/aptos";

export default function Page() {
  return (
    <Box>
      <Heading margin={4} textAlign="center">
        Mint a Aptogotchi NFT
      </Heading>
      <PageContent />
    </Box>
  );
}

function PageContent() {
  const { connected, network } = useWallet();

  if (!connected) {
    return (
      <Alert status="warning" variant="left-accent" marginY={8}>
        <AlertIcon />
        Connect wallet to mint your Aptogotchi NFT.
      </Alert>
    );
  }

  if (network?.chainId != NetworkToChainId[Network.TESTNET].toString()) {
    return (
      <Alert status="info" variant="left-accent" marginY={8}>
        <AlertIcon />
        Please Connect to Testnet.
      </Alert>
    );
  }

  return <Mint />;
}

function Mint() {
  const { account, signAndSubmitTransaction } = useWallet();
  const [name, setName] = useState<string>();
  const [showAlert, setShowAlert] = useState<boolean>(false);

  const onShowAlert = () => {
    setShowAlert(true);
    setInterval(() => {
      setShowAlert(false);
    }, 5000);
  };

  const onSubmit = async () => {
    if (!account) {
      throw new Error("Wallet not connected");
    }
    const body = Math.floor(Math.random() * 4) + 1;
    const ear = Math.floor(Math.random() * 5) + 1;
    const face = Math.floor(Math.random() * 3) + 1;
    const response = await signAndSubmitTransaction({
      sender: account.address,
      data: {
        function: `${APTOGOTCHI_CONTRACT_ADDRESS}::main::create_aptogotchi`,
        typeArguments: [],
        functionArguments: [
          name,
          body.toString(),
          ear.toString(),
          face.toString(),
        ],
      },
    });
    await aptos
      .waitForTransaction({
        transactionHash: response.hash,
      })
      .then(() => {
        console.log("Minted");
        onShowAlert();
      });
  };

  if (showAlert) {
    return (
      <Alert status="success" variant="left-accent">
        <AlertIcon />
        Minted successfully! Go to My Portfolio to see your Aptogotchi.
      </Alert>
    );
  }

  return (
    <Box>
      <Flex flexDirection="column" alignItems="center" marginTop={12}>
        <FormControl
          marginBottom={8}
          display="flex"
          alignItems="center"
          width={480}
          gap={4}
        >
          <FormLabel>Aptogotchi Name</FormLabel>
          <Input
            width={320}
            onChange={(e) => {
              setName(e.target.value);
            }}
          />
        </FormControl>
        <Button width={480} onClick={onSubmit} margin={0}>
          Mint
        </Button>
      </Flex>
    </Box>
  );
}
