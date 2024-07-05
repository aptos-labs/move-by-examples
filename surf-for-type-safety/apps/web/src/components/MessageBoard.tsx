import { surfClient } from "@/utils/aptos";
import { NetworkInfo } from "@aptos-labs/wallet-adapter-react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { useEffect, useState } from "react";
import { as } from "@aptos-labs/ts-sdk/dist/common/accountAddress-NYtf3uZq";

interface MessageBoardProps {
  network: NetworkInfo | null;
}

export function MessageBoard({ network }: MessageBoardProps) {
  const [messageObjects, setMessageObjects] = useState<{ inner: string }[]>([]);

  useEffect(() => {
    surfClient(network)
      .view.get_messages({
        typeArguments: [],
        functionArguments: [null, null],
      })
      .then((res) => {
        setMessageObjects(res[0] as { inner: string }[]);
      });
  }, [network]);

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
