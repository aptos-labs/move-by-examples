import { surfClient } from "@/lib/aptos";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { LabelValueGrid } from "@/components/LabelValueGrid";

interface MessageProps {
  messageObjectAddress: string;
}

export async function Message({ messageObjectAddress }: MessageProps) {
  const [
    booleanContent,
    stringContent,
    numberContent,
    addressContent,
    objectContent,
    vectorContent,
    optionalBooleanContent,
    optionalStringContent,
    optionalNumberContent,
    optionalAddressContent,
    optionalObjectContent,
    optionalVectorContent,
  ] = await surfClient().view.get_message_content({
    typeArguments: [],
    functionArguments: [messageObjectAddress as `0x${string}`],
  });

  return (
    <Card>
      <CardHeader>
        <CardTitle>Message</CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col gap-10 pt-6">
        <div className="flex flex-col gap-6">
          <LabelValueGrid
            items={[
              {
                label: "Boolean Content",
                value: <p>{String(booleanContent)}</p>,
              },
              {
                label: "String Content",
                value: <p>{stringContent}</p>,
              },
              {
                label: "Number Content",
                value: <p>{numberContent}</p>,
              },
              {
                label: "Address Content",
                value: <p>{addressContent}</p>,
              },
              {
                label: "Object Content",
                value: <p>{JSON.stringify(objectContent)}</p>,
              },
              {
                label: "Vector Content",
                value: <p>{JSON.stringify(vectorContent)}</p>,
              },
              {
                label: "Optional Boolean Content",
                // @ts-ignore
                value: <p>{String(optionalBooleanContent.vec)}</p>,
              },
              {
                label: "Optional String Content",
                // @ts-ignore
                value: <p>{optionalStringContent.vec}</p>,
              },
              {
                label: "Optional Number Content",
                // @ts-ignore
                value: <p>{optionalNumberContent.vec}</p>,
              },
              {
                label: "Optional Address Content",
                // @ts-ignore
                value: <p>{optionalAddressContent.vec}</p>,
              },
              {
                label: "Optional Object Content",
                // @ts-ignore
                value: <p>{JSON.stringify(optionalObjectContent.vec)}</p>,
              },
              {
                label: "Optional Vector Content",
                // @ts-ignore
                value: <p>{JSON.stringify(optionalVectorContent.vec)}</p>,
              },
            ]}
          />
        </div>
      </CardContent>
    </Card>
  );
}
