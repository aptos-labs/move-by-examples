"use client";

import { ReactNode } from "react";
import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import { PetraWallet } from "petra-plugin-wallet-adapter";
import { ChakraProvider } from "@chakra-ui/react";
import { CacheProvider } from "@chakra-ui/next-js";

const wallets = [new PetraWallet()];

export function Providers({ children }: { children: ReactNode }) {
  return (
    <CacheProvider>
      <ChakraProvider>
        <AptosWalletAdapterProvider plugins={wallets} autoConnect={true}>
          {children}
        </AptosWalletAdapterProvider>
      </ChakraProvider>
    </CacheProvider>
  );
}
