import { useWallet } from "@aptos-labs/wallet-adapter-react";

import { Header } from "@/components/Header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useHasIssuedShare } from "@/hooks/useIssuer";
import { IssuerDetails } from "@/components/IssuerDetails";
import { IssuerShareHolders } from "@/components/IssuerShareHolders";
import { IssueShare } from "@/components/IssueShare";
import { UserHoldings } from "@/components/UserHoldings";
import { TradeShare } from "@/components/TradeShare";

export function MyProfile() {
  const { connected, account } = useWallet();
  const hasIssuedShare = useHasIssuedShare(account?.address as `0x${string}`);

  return (
    <>
      <Header title="Aptos Friend" />
      <div className="flex items-center justify-center flex-col">
        {connected && account ? (
          <Card>
            <CardContent className="flex flex-col gap-10 pt-6">
              {hasIssuedShare ? (
                <>
                  <IssuerDetails issuerAddress={account.address as `0x${string}`} />
                  <TradeShare issuerAddress={account.address as `0x${string}`} />
                  <IssuerShareHolders issuerAddress={account.address as `0x${string}`} />
                </>
              ) : (
                <IssueShare />
              )}
              <UserHoldings userAddress={account.address as `0x${string}`} />
            </CardContent>
          </Card>
        ) : (
          <CardHeader>
            <CardTitle>Connect a wallet to see your profile</CardTitle>
          </CardHeader>
        )}
      </div>
    </>
  );
}
