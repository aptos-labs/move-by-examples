"use client";

import { IssueKey } from "@/components/IssueKey";
import { MyProfile } from "@/components/MyProfile";
import { useGetHolding } from "@/hooks/useGetHolding";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Box } from "@chakra-ui/react";

export default function Page() {
  const { account } = useWallet();
  const balance = useGetHolding(
    account?.address as `0x${string}`,
    account?.address as `0x${string}`
  );

  if (!account) {
    return <Box>Connecting Wallet</Box>;
  }

  if (!balance) {
    return <Box>Loading...</Box>;
  }

  return balance === "0" ? (
    <IssueKey />
  ) : (
    <MyProfile issuerAddress={account.address as `0x${string}`} />
  );
}
