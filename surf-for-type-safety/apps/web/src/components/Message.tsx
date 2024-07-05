import { surfClient } from "@/utils/aptos";
import { NetworkInfo } from "@aptos-labs/wallet-adapter-react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";

interface MessageProps {
  network: NetworkInfo | null;
}

export async function Message({ network }: MessageProps) {
  const message = await surfClient(network).view.get_message_struct({
    typeArguments: [],
    functionArguments: [null],
  });

  return (
    <Card>
      <CardHeader>
        <CardTitle>Message Board</CardTitle>
      </CardHeader>
      <CardContent className="flex flex-wrap gap-4">
        {/* <Button onClick={onSignAndSubmitTransaction} disabled={!sendable}>
          Sign and submit transaction
        </Button>
        <Button onClick={onSignTransaction} disabled={!sendable}>
          Sign transaction
        </Button>
        <Button onClick={onSignMessage} disabled={!sendable}>
          Sign message
        </Button>
        <Button onClick={onSignMessageAndVerify} disabled={!sendable}>
          Sign message and verify
        </Button> */}
      </CardContent>
    </Card>
  );
}
