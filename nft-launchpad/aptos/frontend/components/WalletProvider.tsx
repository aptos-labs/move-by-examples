import { PropsWithChildren } from "react";
import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";

import { useToast } from "@/components/ui/use-toast";
import { NETWORK } from "@/constants";

export function WalletProvider({ children }: PropsWithChildren) {
  const { toast } = useToast();

  return (
    <AptosWalletAdapterProvider
      autoConnect={true}
      dappConfig={{ network: NETWORK }}
      onError={(error) => {
        toast({
          variant: "destructive",
          title: "Error",
          description: error || "Unknown wallet error",
        });
      }}
    >
      {children}
    </AptosWalletAdapterProvider>
  );
}
