import { Message } from "@/components/Message";

export default function MessagePage({
  params,
}: {
  params: { messageObjectAddress: string };
}) {
  const { messageObjectAddress } = params;

  return <Message messageObjectAddress={messageObjectAddress} />;
}
