"use client";

import { isTestnet } from "@/lib/aptos";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { AlertCircle } from "lucide-react";

import { WalletSelection } from "@/components/wallet/WalletSelection";
import { WalletConnection } from "@/components/wallet/WalletConnection";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";

export const Wallet = () => {
  const { account, connected, network, wallet, changeNetwork } = useWallet();

  return (
    <>
      <WalletSelection />
      {connected && (
        <WalletConnection
          account={account}
          network={network}
          wallet={wallet}
          changeNetwork={changeNetwork}
        />
      )}
      {connected && !isTestnet(connected, network?.name) && (
        <Alert variant="warning">
          <AlertCircle className="h-4 w-4" />
          <AlertTitle>Warning</AlertTitle>
          <AlertDescription>
            The transactions flows below will only work on testnet.
          </AlertDescription>
        </Alert>
      )}
    </>
  );
};
