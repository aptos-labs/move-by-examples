import { FungibleAssetInfo } from "@/components/FungibleAssetInfo";
import { MintFungibleAsset } from "@/components/MintFungibleAsset";
import { Box, Card, CardBody, CardFooter, CardHeader } from "@chakra-ui/react";

type Props = {
  params: { address: string };
};

export default function Page({ params: { address } }: Props) {
  return (
    <Card>
      <CardHeader>
        <Box textAlign="center" fontSize="xl">
          User Created Fungible Asset
        </Box>
      </CardHeader>
      <CardBody>
        <FungibleAssetInfo fungibleAssetAddress={address} />
      </CardBody>
      <CardFooter justifyContent="center">
        <MintFungibleAsset fungibleAssetAddress={address} />
      </CardFooter>
    </Card>
  );
}
