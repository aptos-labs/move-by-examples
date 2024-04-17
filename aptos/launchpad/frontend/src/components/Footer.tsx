import React from "react";
import { Flex, HStack, Link, Text } from "@chakra-ui/react";
import { WalletButtons } from "@/components/WalletButtons";

export const Footer = () => {
  return (
    <Flex
      bg="teal.600"
      color="white"
      px={16}
      py={4}
      justify="space-between"
      align="center"
    >
      <Link
        px={4}
        py={4}
        rounded={"md"}
        fontWeight={"bold"}
        _hover={{ textDecoration: "none", bg: "teal.600" }}
        href="/"
      >
        <Text fontSize="xl" fontWeight="bold">
          Fungible Asset
        </Text>
        <Text fontSize="xl" fontWeight="bold">
          Launchpad
        </Text>
      </Link>
      <HStack>
        <Link
          px={4}
          py={4}
          rounded={"md"}
          fontWeight={"bold"}
          _hover={{ textDecoration: "none", bg: "teal.600" }}
          href="/"
        >
          Explorer
        </Link>
        <Link
          px={4}
          py={4}
          rounded={"md"}
          fontWeight={"bold"}
          _hover={{ textDecoration: "none", bg: "teal.600" }}
          href="/create"
        >
          Create
        </Link>
      </HStack>
      <WalletButtons />
    </Flex>
  );
};
