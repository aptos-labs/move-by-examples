import { useParams } from "react-router-dom";

import { Header } from "@/components/Header";
import { Card, CardContent } from "@/components/ui/card";
import { IssuerDetails } from "@/components/IssuerDetails";
import { IssuerShareHolders } from "@/components/IssuerShareHolders";
import { UserHoldings } from "@/components/UserHoldings";
import { TradeShare } from "@/components/TradeShare";

export function Issuer() {
  const { issuerAddress } = useParams();

  return (
    <>
      <Header title="Aptos Friend" />
      <div className="flex items-center justify-center flex-col">
        <Card>
          <CardContent className="flex flex-col gap-10 pt-6">
            <IssuerDetails issuerAddress={issuerAddress as `0x${string}`} />
            <TradeShare issuerAddress={issuerAddress as `0x${string}`} />
            <IssuerShareHolders issuerAddress={issuerAddress as `0x${string}`} />
            <UserHoldings userAddress={issuerAddress as `0x${string}`} />
          </CardContent>
        </Card>
      </div>
    </>
  );
}
