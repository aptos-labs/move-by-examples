import { surfClient } from "@/utils/aptos";
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
  Box,
} from "@chakra-ui/react";

export const Registry = async () => {
  const registry = await surfClient.view
    .get_issuer_registry({
      typeArguments: [],
      functionArguments: [],
    })
    .then((res) => {
      const issuerObjects = res[0] as { inner: `0x${string}` }[];
      return issuerObjects.map((issuerObject) => issuerObject.inner);
    });

  return registry ? (
    <TableContainer>
      <Table variant="simple">
        <TableCaption>
          <Box>Discover all users who have issued keys. </Box>
        </TableCaption>
        <Thead>
          <Tr>
            <Th textAlign="center">Issuer Object Address</Th>
          </Tr>
        </Thead>
        <Tbody>
          {registry.map((issuerObjectAddress) => {
            return (
              <Tr key={issuerObjectAddress}>
                <Td textAlign="center">
                  <Link href={`/issuer/${issuerObjectAddress}`}>
                    {issuerObjectAddress}
                  </Link>
                </Td>
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
