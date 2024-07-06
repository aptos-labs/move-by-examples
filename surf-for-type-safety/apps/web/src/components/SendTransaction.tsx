"use client";

import { MultiAgent } from "@/components/transactionFlows/MultiAgent";
import { PostMessageWithSurf } from "@/components/transactionFlows/PostMessageWithSurf";
import { SingleSigner } from "@/components/transactionFlows/SingleSigner";
import { Sponsor } from "@/components/transactionFlows/Sponsor";
import { useWallet } from "@aptos-labs/wallet-adapter-react";

export const SendTransaction = () => {
  const { connected } = useWallet();

  return (
    connected && (
      <>
        <PostMessageWithSurf />
        <SingleSigner />
        <Sponsor />
        <MultiAgent />
      </>
    )
  );
};
