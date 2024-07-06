import { useAutoConnect } from "@/components/providers/AutoConnectProvider";
import { WalletSelector as ShadcnWalletSelector } from "@/components/wallet/WalletSelector";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";

export const WalletSelection = () => {
  const { autoConnect, setAutoConnect } = useAutoConnect();

  return (
    <Card>
      <CardHeader>
        <CardTitle>Wallet Selection</CardTitle>
        <CardDescription>
          Connect a wallet using one of the following wallet selectors.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="flex flex-wrap gap-6 pt-6 pb-12 justify-between items-center">
          <div className="flex flex-col gap-4 items-center">
            <div className="text-sm text-muted-foreground">shadcn/ui</div>
            <ShadcnWalletSelector />
          </div>
        </div>
        <label className="flex items-center gap-4 cursor-pointer">
          <Switch
            id="auto-connect-switch"
            checked={autoConnect}
            onCheckedChange={setAutoConnect}
          />
          <Label htmlFor="auto-connect-switch">
            Auto reconnect on page load
          </Label>
        </label>
      </CardContent>
    </Card>
  );
};
