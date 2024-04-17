"use client";

import { useGetRegistry } from "@/hooks/useGetRegistry";
import {
  Table,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
  TableCaption,
  TableContainer,
  Link,
} from "@chakra-ui/react";

export const Registry = () => {
  const registry = useGetRegistry();
  return registry ? (
    <TableContainer>
      <Table variant="simple">
        <TableCaption>
          All fungible assets created by the launchpad
        </TableCaption>
        <Thead>
          <Tr>
            <Th>FA Address</Th>
          </Tr>
        </Thead>
        <Tbody>
          {registry.map((faAddress) => {
            return (
              <Tr key={faAddress}>
                <Link href={`/fungible_asset/${faAddress}`}>
                  <Td>{faAddress}</Td>
                </Link>
              </Tr>
            );
          })}
        </Tbody>
      </Table>
    </TableContainer>
  ) : (
    <></>
  );
};
