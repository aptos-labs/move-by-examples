import { surfClient } from "@/utils/aptos";
import { Card, CardHeader, CardBody, CardFooter, Box } from "@chakra-ui/react";
import { IssuerInfo } from "./IssuerInfo";
import { TradeKey } from "./TradeKey";

type Props = {
  issuerObjectAddress: `0x${string}`;
};

export const Issuer = async ({ issuerObjectAddress }: Props) => {
  const issuerInfo = await surfClient.view
    .get_issuer({
      typeArguments: [],
      functionArguments: [issuerObjectAddress as `0x${string}`],
    })
    .then((res) => {
      const holderHoldingObjects = res[3] as { inner: `0x${string}` }[];
      return {
        issuerAddress: res[0],
        username: res[1],
        totalIssuedShares: parseInt(res[2]),
        holderHoldingObjects: holderHoldingObjects.map(
          (holder) => holder.inner
        ),
      };
    });

  return (
    <Card>
      <CardHeader>
        <Box textAlign="center" fontSize="xl">
          User Issued Key
        </Box>
      </CardHeader>
      <CardBody>
        <IssuerInfo
          issuerObjectAddress={issuerObjectAddress}
          issuerInfo={issuerInfo}
        />
      </CardBody>
      <CardFooter justifyContent="center">
        <TradeKey issuerInfo={issuerInfo} />
      </CardFooter>
    </Card>
  );
};
