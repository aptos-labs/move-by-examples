'use client';

import { FriendTechIDL, getFriendTechProgramId } from '@friend-tech/anchor';
import { Program } from '@coral-xyz/anchor';
import { useConnection } from '@solana/wallet-adapter-react';
import { Cluster, Keypair, PublicKey } from '@solana/web3.js';
import { useMutation, useQuery } from '@tanstack/react-query';
import { useMemo } from 'react';
import toast from 'react-hot-toast';
import { useCluster } from '../cluster/cluster-data-access';
import { useAnchorProvider } from '../solana/solana-provider';
import { useTransactionToast } from '../ui/ui-layout';

export function useFriendTechProgram() {
  const { connection } = useConnection();
  const { cluster } = useCluster();
  const transactionToast = useTransactionToast();
  const provider = useAnchorProvider();
  const programId = useMemo(
    () => getFriendTechProgramId(cluster.network as Cluster),
    [cluster]
  );
  const program = new Program(FriendTechIDL, programId, provider);

  const accounts = useQuery({
    queryKey: ['friend-tech', 'all', { cluster }],
    queryFn: () => program.account.friendTech.all(),
  });

  const getProgramAccount = useQuery({
    queryKey: ['get-program-account', { cluster }],
    queryFn: () => connection.getParsedAccountInfo(programId),
  });

  const initialize = useMutation({
    mutationKey: ['friend-tech', 'initialize', { cluster }],
    mutationFn: (keypair: Keypair) =>
      program.methods
        .initialize()
        .accounts({ friendTech: keypair.publicKey })
        .signers([keypair])
        .rpc(),
    onSuccess: (signature) => {
      transactionToast(signature);
      return accounts.refetch();
    },
    onError: () => toast.error('Failed to initialize account'),
  });

  return {
    program,
    programId,
    accounts,
    getProgramAccount,
    initialize,
  };
}

export function useFriendTechProgramAccount({
  account,
}: {
  account: PublicKey;
}) {
  const { cluster } = useCluster();
  const transactionToast = useTransactionToast();
  const { program, accounts } = useFriendTechProgram();

  const accountQuery = useQuery({
    queryKey: ['friend-tech', 'fetch', { cluster, account }],
    queryFn: () => program.account.friendTech.fetch(account),
  });

  const closeMutation = useMutation({
    mutationKey: ['friend-tech', 'close', { cluster, account }],
    mutationFn: () =>
      program.methods.close().accounts({ friendTech: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accounts.refetch();
    },
  });

  const decrementMutation = useMutation({
    mutationKey: ['friend-tech', 'decrement', { cluster, account }],
    mutationFn: () =>
      program.methods.decrement().accounts({ friendTech: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accountQuery.refetch();
    },
  });

  const incrementMutation = useMutation({
    mutationKey: ['friend-tech', 'increment', { cluster, account }],
    mutationFn: () =>
      program.methods.increment().accounts({ friendTech: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accountQuery.refetch();
    },
  });

  const setMutation = useMutation({
    mutationKey: ['friend-tech', 'set', { cluster, account }],
    mutationFn: (value: number) =>
      program.methods.set(value).accounts({ friendTech: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accountQuery.refetch();
    },
  });

  return {
    accountQuery,
    closeMutation,
    decrementMutation,
    incrementMutation,
    setMutation,
  };
}
