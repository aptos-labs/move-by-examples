"use client";

import { useGetFungibleAssetCurrentSupply } from "@/hooks/useGetFungibleAssetCurrentSupply";
import { useGetFungibleAssetMaxSupply } from "@/hooks/useGetFungibleAssetMaxSupply";
import { useGetFungibleAssetMetadata } from "@/hooks/useGetFungibleAssetMetadata";
import { Heading, Box, Stack, StackDivider, Text } from "@chakra-ui/react";

type Props = {
  fungibleAssetAddress: string;
};

export const FungibleAssetInfo = ({ fungibleAssetAddress }: Props) => {
  const metadata = useGetFungibleAssetMetadata(fungibleAssetAddress);
  const maxSupply = useGetFungibleAssetMaxSupply(fungibleAssetAddress);
  const currentSupply = useGetFungibleAssetCurrentSupply(fungibleAssetAddress);
  return (
    metadata &&
    maxSupply &&
    currentSupply && (
      <Stack divider={<StackDivider />} spacing="4">
        <Box>
          <Heading size="xs" textTransform="uppercase">
            Name
          </Heading>
          <Text pt="2" fontSize="sm">
            {metadata.name}
          </Text>
        </Box>
        <Box>
          <Heading size="xs" textTransform="uppercase">
            Symbol
          </Heading>
          <Text pt="2" fontSize="sm">
            {metadata.symbol}
          </Text>
        </Box>
        <Box>
          <Heading size="xs" textTransform="uppercase">
            Decimals
          </Heading>
          <Text pt="2" fontSize="sm">
            {metadata.decimals}
          </Text>
        </Box>
        <Box>
          <Heading size="xs" textTransform="uppercase">
            Max Supply
          </Heading>
          <Text pt="2" fontSize="sm">
            {maxSupply}
          </Text>
        </Box>
        <Box>
          <Heading size="xs" textTransform="uppercase">
            Current Supply
          </Heading>
          <Text pt="2" fontSize="sm">
            {currentSupply}
          </Text>
        </Box>
      </Stack>
    )
  );
};
