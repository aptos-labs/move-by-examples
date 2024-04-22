import React from "react";
import { Flex, HStack, Link, Text } from "@chakra-ui/react";
import { WalletButtons } from "@/components/WalletButtons";

export const NavBar = () => {
  return (
    <Flex
      bg="teal.600"
      color="white"
      px={16}
      py={4}
      justifyContent="space-between"
      alignItems="center"
      position="relative"
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
      <HStack
        position="absolute"
        left="50%"
        transform="translateX(-50%)"
        spacing={8}
      >
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
