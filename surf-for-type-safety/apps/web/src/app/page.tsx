import { MessageBoard } from "@/components/MessageBoard";
import { Wallet } from "@/components/wallet/Wallet";
import { SendTransaction } from "@/components/SendTransaction";

export default function HomePage() {
  return (
    <>
      <Wallet />
      <MessageBoard />
      <SendTransaction />
    </>
  );
}
