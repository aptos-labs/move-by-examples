import { FungibleAssetInfo } from "@/components/FungibleAssetInfo";
import { MintFungibleAsset } from "@/components/MintFungibleAsset";
import { surfClient } from "@/utils/aptos";
import { Box, Card, CardBody, CardFooter, CardHeader } from "@chakra-ui/react";

type Props = {
  params: { address: string };
};

export default async function Page({ params: { address } }: Props) {
  const metadata = await surfClient.view
    .get_metadata({
      typeArguments: [],
      functionArguments: [address as `0x${string}`],
    })
    .then((res) => {
      return {
        name: res[0] as string,
        symbol: res[1] as string,
        decimals: res[2] as number,
      };
    });

  return (
    <Card>
      <CardHeader>
        <Box textAlign="center" fontSize="xl">
          User Created Fungible Asset
        </Box>
      </CardHeader>
      <CardBody>
        <FungibleAssetInfo fungibleAssetAddress={address} metadata={metadata} />
      </CardBody>
      <CardFooter justifyContent="center">
        <MintFungibleAsset
          fungibleAssetAddress={address}
          decimals={metadata.decimals}
        />
      </CardFooter>
    </Card>
  );
}
