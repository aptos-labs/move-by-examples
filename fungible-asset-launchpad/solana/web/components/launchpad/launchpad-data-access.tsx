'use client';

import { LaunchpadIDL, getLaunchpadProgramId } from '@launchpad/anchor';
import { Program } from '@coral-xyz/anchor';
import { useConnection } from '@solana/wallet-adapter-react';
import { Cluster, Keypair, PublicKey } from '@solana/web3.js';
import { useMutation, useQuery } from '@tanstack/react-query';
import { useMemo } from 'react';
import toast from 'react-hot-toast';
import { useCluster } from '../cluster/cluster-data-access';
import { useAnchorProvider } from '../solana/solana-provider';
import { useTransactionToast } from '../ui/ui-layout';

export function useLaunchpadProgram() {
  const { connection } = useConnection();
  const { cluster } = useCluster();
  const transactionToast = useTransactionToast();
  const provider = useAnchorProvider();
  const programId = useMemo(
    () => getLaunchpadProgramId(cluster.network as Cluster),
    [cluster]
  );
  const program = new Program(LaunchpadIDL, programId, provider);

  const accounts = useQuery({
    queryKey: ['launchpad', 'all', { cluster }],
    queryFn: () => program.account.launchpad.all(),
  });

  const getProgramAccount = useQuery({
    queryKey: ['get-program-account', { cluster }],
    queryFn: () => connection.getParsedAccountInfo(programId),
  });

  const initialize = useMutation({
    mutationKey: ['launchpad', 'initialize', { cluster }],
    mutationFn: (keypair: Keypair) =>
      program.methods
        .initialize()
        .accounts({ launchpad: keypair.publicKey })
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

export function useLaunchpadProgramAccount({
  account,
}: {
  account: PublicKey;
}) {
  const { cluster } = useCluster();
  const transactionToast = useTransactionToast();
  const { program, accounts } = useLaunchpadProgram();

  const accountQuery = useQuery({
    queryKey: ['launchpad', 'fetch', { cluster, account }],
    queryFn: () => program.account.launchpad.fetch(account),
  });

  const closeMutation = useMutation({
    mutationKey: ['launchpad', 'close', { cluster, account }],
    mutationFn: () =>
      program.methods.close().accounts({ launchpad: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accounts.refetch();
    },
  });

  const decrementMutation = useMutation({
    mutationKey: ['launchpad', 'decrement', { cluster, account }],
    mutationFn: () =>
      program.methods.decrement().accounts({ launchpad: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accountQuery.refetch();
    },
  });

  const incrementMutation = useMutation({
    mutationKey: ['launchpad', 'increment', { cluster, account }],
    mutationFn: () =>
      program.methods.increment().accounts({ launchpad: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accountQuery.refetch();
    },
  });

  const setMutation = useMutation({
    mutationKey: ['launchpad', 'set', { cluster, account }],
    mutationFn: (value: number) =>
      program.methods.set(value).accounts({ launchpad: account }).rpc(),
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
