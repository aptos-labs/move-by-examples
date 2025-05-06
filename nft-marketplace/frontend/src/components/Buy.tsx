import { ABI } from "@/utils/abi";
import { APT, aptos } from "@/utils/aptos";
import { Listing } from "@/utils/types";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Button, Text, HStack, Box } from "@chakra-ui/react";
import Link from "next/link";

type Props = {
  listing: Listing;
};

export const Buy = ({ listing }: Props) => {
  const { account, signAndSubmitTransaction } = useWallet();

  const onSubmit = async () => {
    if (!account) {
      throw new Error("Wallet not connected");
    }
    const response = await signAndSubmitTransaction({
      sender: account.address,
      data: {
        function: `${ABI.address}::marketplace::purchase`,
        typeArguments: [APT],
        functionArguments: [listing.listing_object_address],
      },
    });
    await aptos
      .waitForTransaction({
        transactionHash: response.hash,
      })
      .then(() => {
        console.log("Bought");
      });
  };

  return (
    <HStack flexDirection="column">
      <Box display="flex" gap={2}>
        <Text>Price: </Text>
        <Text fontWeight="bold">{listing.price} APT</Text>
      </Box>
      <Button width={160} onClick={onSubmit}>
        Buy
      </Button>
      <Link
        href={`https://explorer.aptoslabs.com/account/${listing.seller_address}?network=testnet`}
        rel="noopener noreferrer"
        target="_blank"
      >
        <Text fontSize="xs" color="GrayText">
          View seller on explorer
        </Text>
      </Link>
    </HStack>
  );
};
