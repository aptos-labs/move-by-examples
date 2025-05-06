import React from "react";
import { Box, Flex, HStack, Link, Text } from "@chakra-ui/react";
import NextLink from "next/link";
import { WalletButtons } from "./WalletButtons";

export const NavBar = () => {
  return (
    <Flex
      bg="teal.600"
      color="white"
      px={16}
      py={4}
      justifyContent="space-between"
      alignItems="center"
    >
      <Box>
        <Text fontSize="xl" fontWeight="bold">
          Aptogotchi
        </Text>
        <Text fontSize="xl" fontWeight="bold">
          NFT Marketplace
        </Text>
      </Box>
      <HStack>
        <NextLink href="/" passHref>
          <Text
            px={4}
            py={4}
            rounded={"md"}
            fontWeight={"bold"}
            _hover={{ textDecoration: "none", bg: "teal.600" }}
          >
            Home
          </Text>
        </NextLink>
        <NextLink href="/mint" passHref>
          <Text
            px={4}
            py={4}
            rounded={"md"}
            fontWeight={"bold"}
            _hover={{ textDecoration: "none", bg: "teal.600" }}
          >
            Mint
          </Text>
        </NextLink>
        <NextLink href="/portfolio" passHref>
          <Text
            px={4}
            py={4}
            rounded={"md"}
            fontWeight={"bold"}
            _hover={{ textDecoration: "none", bg: "teal.600" }}
          >
            My Portfolio
          </Text>
        </NextLink>
      </HStack>
      <WalletButtons />
    </Flex>
  );
};
