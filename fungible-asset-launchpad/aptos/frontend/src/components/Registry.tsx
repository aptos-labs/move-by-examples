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
  VStack,
} from "@chakra-ui/react";

export const Registry = async () => {
  const registry = await surfClient.view
    .get_registry({
      typeArguments: [],
      functionArguments: [],
    })
    .then((res) => {
      const faObjects = res[0] as { inner: string }[];
      return faObjects.map((faObject) => faObject.inner);
    });

  return registry ? (
    <TableContainer>
      <Table variant="simple">
        <TableCaption>
          <VStack>
            <Box>Discover all fungible assets created by the launchpad. </Box>
            <Link
              href="https://learn.aptoslabs.com/example/ERC-20-token-standard"
              target="_blank"
              color="blue.500"
            >
              Learn more about the Fungible Asset Standard
            </Link>
          </VStack>
        </TableCaption>
        <Thead>
          <Tr>
            <Th textAlign="center">FA Address</Th>
          </Tr>
        </Thead>
        <Tbody>
          {registry.map((faAddress) => {
            return (
              <Tr key={faAddress}>
                <Td textAlign="center">
                  <Link href={`/fungible_asset/${faAddress}`}>{faAddress}</Link>
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
