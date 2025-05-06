"use client";

import { WalletProvider } from "@/context/WalletProvider";
import { ChakraProvider } from "@chakra-ui/react";
import { ReactNode } from "react";

export function Providers({ children }: { children: ReactNode }) {
  return (
    <ChakraProvider>
      <WalletProvider>{children}</WalletProvider>
    </ChakraProvider>
  );
}
