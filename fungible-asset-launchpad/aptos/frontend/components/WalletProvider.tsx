import { PropsWithChildren } from "react";
import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
// Internal components
import { useToast } from "@/components/ui/use-toast";
// Internal constants
import { NETWORK } from "@/constants";

export function WalletProvider({ children }: PropsWithChildren) {
  const { toast } = useToast();

  return (
    <AptosWalletAdapterProvider
      autoConnect={true}
      dappConfig={{ network: NETWORK }}
      onError={(error: Error | string | unknown) => {
        // Handle specific TypeError related to 'in' operator with undefined
        if (error instanceof TypeError && error.message?.includes("Cannot use 'in' operator")) {
          console.warn("Wallet adapter error: Received undefined wallet response", error);
          // Don't show toast for this specific error as it's likely a transient wallet extension issue
          return;
        }

        // Log all errors for debugging
        console.error("Wallet error:", error);

        // Show user-friendly error message
        const errorMessage =
          typeof error === "string"
            ? error
            : error instanceof Error
              ? error.message
              : "Unknown wallet error";

        toast({
          variant: "destructive",
          title: "Wallet Error",
          description: errorMessage,
        });
      }}
    >
      {children}
    </AptosWalletAdapterProvider>
  );
}
