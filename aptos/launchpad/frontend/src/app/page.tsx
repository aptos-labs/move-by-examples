import { Registry } from "@/components/Registry";
import { HStack, Heading } from "@chakra-ui/react";

export default function Page() {
  return (
    <HStack flexDirection="column">
      <Heading margin={4} textAlign="center">
        Discover All Fungible Assets Created on the Launchpad
      </Heading>
      <Heading margin={4} textAlign="center">
        Learn more about the fungible asset standard
      </Heading>
      <Registry />
    </HStack>
  );
}
