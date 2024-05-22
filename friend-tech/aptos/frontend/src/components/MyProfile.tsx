"use client";

import { surfClient } from "@/utils/aptos";
import { Card, CardHeader, CardBody, CardFooter, Box } from "@chakra-ui/react";
import { IssuerInfo } from "./IssuerInfo";
import { TradeKey } from "./TradeKey";
import { useEffect, useState } from "react";

type Props = {
  issuerAddress: `0x${string}`;
};

export const MyProfile = ({ issuerAddress }: Props) => {
  const [issuerObjectAddress, setIssuerObjectAddress] =
    useState<`0x${string}`>();
  const [issuerInfo, setIssuerInfo] = useState<{
    issuerAddress: `0x${string}`;
    username: string;
    totalIssuedShares: number;
    holderHoldingObjects: `0x${string}`[];
  }>();
  useEffect(() => {
    surfClient.view
      .get_issuer_obj_addr({
        typeArguments: [],
        functionArguments: [issuerAddress],
      })
      .then(async (res) => {
        const issuerObjectAddress = res[0];
        setIssuerObjectAddress(issuerObjectAddress);
        surfClient.view
          .get_issuer({
            typeArguments: [],
            functionArguments: [issuerObjectAddress as `0x${string}`],
          })
          .then((res) => {
            const holderHoldingObjects = res[3] as { inner: `0x${string}` }[];
            setIssuerInfo({
              issuerAddress: res[0],
              username: res[1],
              totalIssuedShares: parseInt(res[2]),
              holderHoldingObjects: holderHoldingObjects.map(
                (holder) => holder.inner
              ),
            });
          })
          .catch((e) => {
            console.error("error getting issuer", e);
          });
      })
      .catch((e) => {
        console.error("error getting issuer obj addr", e);
      });
  }, [issuerAddress]);

  if (!issuerInfo || !issuerObjectAddress) {
    return <Box>Loading...</Box>;
  }

  return (
    <Card>
      <CardHeader>
        <Box textAlign="center" fontSize="xl">
          Key Issued By Me
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
