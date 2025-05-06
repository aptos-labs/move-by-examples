import Image from "next/image";
import { Box, Card, Text, HStack } from "@chakra-ui/react";
import { BASE_PATH, bodies, ears, faces } from "@/utils/constants";
import Link from "next/link";
import {
  AptogotchiWithTraits,
  ListedAptogotchiWithTraits,
} from "@/utils/types";
import { ReactNode } from "react";

type Props = {
  children?: ReactNode;
  nft: AptogotchiWithTraits | ListedAptogotchiWithTraits;
};

export const NftCard = ({ nft, children }: Props) => {
  const headUrl = BASE_PATH + "head.png";
  const bodyUrl = BASE_PATH + bodies[nft.body];
  const earUrl = BASE_PATH + ears[nft.ear];
  const faceUrl = BASE_PATH + faces[nft.face];

  const aptogotchiImage = (
    <Box position={"relative"} height="100px" width="100px">
      <Box position={"absolute"} top={"0px"} left={"0px"}>
        <Image src={headUrl} alt="pet head" height="100" width="100" />
      </Box>
      <Box position={"absolute"} top={"0px"} left={"0px"}>
        <Image src={bodyUrl} alt="pet body" height="100" width="100" />
      </Box>
      <Box position={"absolute"} top={"0px"} left={"0px"}>
        <Image src={earUrl} alt="pet ears" height="100" width="100" />
      </Box>
      <Box position={"absolute"} top={"0px"} left={"0px"}>
        <Image src={faceUrl} alt="pet face" height="100" width="100" />
      </Box>
    </Box>
  );

  return (
    <Card>
      <HStack
        spacing={2}
        flexDirection="column"
        marginY={6}
        marginX={4}
        width={240}
      >
        {aptogotchiImage}
        <Box display="flex" gap={2}>
          <Text fontSize="xl">Name: </Text>
          <Text fontSize="xl" fontWeight="bold">
            {nft.name}
          </Text>
        </Box>
        <Link
          href={`https://explorer.aptoslabs.com/object/${nft.address}?network=testnet`}
          rel="noopener noreferrer"
          target="_blank"
        >
          <Text fontSize="xs" color="GrayText">
            View NFT on Explorer
          </Text>
        </Link>
        <Box marginTop={6}>{children}</Box>
      </HStack>
    </Card>
  );
};
