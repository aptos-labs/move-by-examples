import { FungibleAssetInfo } from "@/components/FungibleAssetInfo";
import { MintFungibleAsset } from "@/components/MintFungibleAsset";
import { Box, Card, CardBody, CardFooter } from "@chakra-ui/react";

type Props = {
  params: { address: string };
};

export default function Page({ params: { address } }: Props) {
  return (
    <Box>
      <Card>
        <CardBody>
          <FungibleAssetInfo fungibleAssetAddress={address} />
        </CardBody>
        <CardFooter>
          <MintFungibleAsset fungibleAssetAddress={address} />
        </CardFooter>
      </Card>
    </Box>
  );
}
