"use client";

import { surfClient } from "@/utils/aptos";
import {
  Heading,
  Box,
  VStack,
  StackDivider,
  Text,
  Link,
  Table,
  TableCaption,
  TableContainer,
  Tbody,
  Td,
  Th,
  Thead,
  Tr,
} from "@chakra-ui/react";
import { useState, useEffect } from "react";

type Props = {
  issuerObjectAddress: `0x${string}`;
  issuerInfo: {
    issuerAddress: `0x${string}`;
    username: string;
    totalIssuedShares: number;
    holderHoldingObjects: `0x${string}`[];
  };
};

export const IssuerInfo = ({ issuerObjectAddress, issuerInfo }: Props) => {
  const [holderHoldings, setHolderHoldings] =
    useState<{ holderAddress: `0x${string}`; balance: string }[]>();
  useEffect(() => {
    Promise.all(
      issuerInfo.holderHoldingObjects.map(async (holderHoldingObject) => {
        const holderHolding = await surfClient.view
          .get_holding({
            typeArguments: [],
            functionArguments: [holderHoldingObject],
          })
          .then((res) => {
            return {
              holderAddress: res[1],
              balance: res[2],
            };
          });
        return holderHolding;
      })
    ).then((holderHoldings) => {
      setHolderHoldings(holderHoldings);
    });
  }, [issuerInfo.holderHoldingObjects]);

  return (
    <VStack divider={<StackDivider />} spacing="4" textAlign="center">
      <Box>
        <Heading size="xs" textTransform="uppercase">
          Issuer Username
        </Heading>
        <Text pt="2" fontSize="sm">
          {issuerInfo.username}
        </Text>
      </Box>
      <Box>
        <Heading size="xs" textTransform="uppercase">
          Total Issued Shares
        </Heading>
        <Text pt="2" fontSize="sm">
          {issuerInfo.totalIssuedShares}
        </Text>
      </Box>
      <Box>
        <Heading size="xs" textTransform="uppercase">
          View Issuer Address on Explorer
        </Heading>
        <Link
          target="_blank"
          href={`https://explorer.aptoslabs.com/account/${issuerInfo.issuerAddress}?network=testnet`}
        >
          <Text pt="2" fontSize="sm">
            {issuerInfo.issuerAddress}
          </Text>
        </Link>
      </Box>
      <Box>
        <Heading size="xs" textTransform="uppercase">
          View Issuer Object on Explorer
        </Heading>
        <Link
          target="_blank"
          href={`https://explorer.aptoslabs.com/object/${issuerObjectAddress}?network=testnet`}
        >
          <Text pt="2" fontSize="sm">
            {issuerObjectAddress}
          </Text>
        </Link>
      </Box>
      <TableContainer>
        <Table>
          <TableCaption>All Key Holders</TableCaption>
          <Thead>
            <Tr>
              <Th>Holder Address</Th>
              <Th>Balance</Th>
            </Tr>
          </Thead>
          <Tbody>
            {holderHoldings &&
              holderHoldings.map((holderHolding, index) => (
                <Tr key={index}>
                  <Td>
                    <Link
                      target="_blank"
                      href={`https://explorer.aptoslabs.com/account/${holderHolding.holderAddress}?network=testnet`}
                    >
                      <Text pt="2" fontSize="sm">
                        {holderHolding.holderAddress}
                      </Text>
                    </Link>
                  </Td>
                  <Td>{holderHolding.balance}</Td>
                </Tr>
              ))}
          </Tbody>
        </Table>
      </TableContainer>
    </VStack>
  );
};
