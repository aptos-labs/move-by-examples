import { Mizu } from "@mizuwallet-sdk/core";
import { truncateAddress } from "@aptos-labs/wallet-adapter-react";
import { Network } from "@aptos-labs/ts-sdk";
import { Copy, LogOut } from "lucide-react";
import { useCallback, useEffect } from "react";
// Internal components
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useToast } from "@/components/ui/use-toast";
import { useMizuWallet } from "@/components/WalletProvider";

export function WalletSelector() {
  const { mizuClient, setMizuClient, userAddress, setUserAddress } = useMizuWallet();

  const { toast } = useToast();

  const copyAddress = useCallback(async () => {
    if (!userAddress) return;
    try {
      await navigator.clipboard.writeText(userAddress);
      toast({
        title: "Success",
        description: "Copied wallet address to clipboard.",
      });
    } catch {
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to copy wallet address.",
      });
    }
  }, [userAddress, toast]);

  useEffect(() => {
    if (!mizuClient) return;
    mizuClient.getUserWalletAddress().then((addr) => setUserAddress(addr));
  }, [mizuClient]);

  return mizuClient ? (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button>{truncateAddress(userAddress) || "Unknown"}</Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem onSelect={copyAddress} className="gap-2">
          <Copy className="h-4 w-4" /> Copy address
        </DropdownMenuItem>
        <DropdownMenuItem onSelect={mizuClient.logout} className="gap-2">
          <LogOut className="h-4 w-4" /> Disconnect
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  ) : (
    <Button
      onClick={async () => {
        const mizu = new Mizu({
          appId: import.meta.env.VITE_MIZU_WALLET_APP_ID,
          network: Network.TESTNET,
        });
        await mizu.loginInTG((window as any).Telegram.WebApp.initData);
        setMizuClient(mizu);
      }}
    >
      Connect Mizu Wallet
    </Button>
  );
}
