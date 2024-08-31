import React, { createContext, useContext, useState } from "react";
import { Mizu } from "@mizuwallet-sdk/core";

interface MizuWalletContextType {
  mizuClient?: Mizu;
  userAddress?: string;
  setMizuClient: (account?: Mizu) => void;
  setUserAddress: (address?: string) => void;
}

const MizuWalletContext = createContext<MizuWalletContextType | undefined>(undefined);

export const WalletProvider: React.FC<{
  children: React.ReactNode;
}> = ({ children }) => {
  const [mizuClient, setMizuClient] = useState<Mizu>();
  const [userAddress, setUserAddress] = useState<string>();

  return (
    <MizuWalletContext.Provider value={{ mizuClient, setMizuClient, userAddress, setUserAddress }}>
      {children}
    </MizuWalletContext.Provider>
  );
};

export const useMizuWallet = () => {
  const context = useContext(MizuWalletContext);
  if (!context) {
    throw new Error("useMizuWallet must be used within a MizuWalletProvider");
  }
  return context;
};
