import { surfClient } from "@/utils/aptos";
import {
  Heading,
  Box,
  Stack,
  StackDivider,
  Text,
  Link,
} from "@chakra-ui/react";

type Props = {
  fungibleAssetAddress: string;
};

export const FungibleAssetInfo = async ({ fungibleAssetAddress }: Props) => {
  const metadata = await surfClient.view
    .get_metadata({
      typeArguments: [],
      functionArguments: [fungibleAssetAddress as `0x${string}`],
    })
    .then((res) => {
      return {
        name: res[0] as string,
        symbol: res[1] as string,
        decimals: res[2] as number,
      };
    });

  const maxSupply = await surfClient.view
    .get_max_supply({
      typeArguments: [],
      functionArguments: [fungibleAssetAddress as `0x${string}`],
    })
    .then((res) => {
      return res[0] as string;
    });

  const currentSupply = await surfClient.view
    .get_current_supply({
      typeArguments: [],
      functionArguments: [fungibleAssetAddress as `0x${string}`],
    })
    .then((res) => {
      return res[0] as string;
    });

  return (
    metadata &&
    maxSupply &&
    currentSupply && (
      <Stack divider={<StackDivider />} spacing="4" textAlign="center">
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
        <Box>
          <Heading size="xs" textTransform="uppercase">
            View on explorer
          </Heading>
          <Link
            target="_blank"
            href={`https://explorer.aptoslabs.com/object/${fungibleAssetAddress}?network=testnet`}
          >
            <Text pt="2" fontSize="sm">
              {fungibleAssetAddress}
            </Text>
          </Link>
        </Box>
      </Stack>
    )
  );
};
