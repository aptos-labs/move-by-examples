'use client';

import {
  SimpleTodoListIDL,
  getSimpleTodoListProgramId,
} from '@simple-todo-list/anchor';
import { Program } from '@coral-xyz/anchor';
import { useConnection } from '@solana/wallet-adapter-react';
import { Cluster, Keypair, PublicKey } from '@solana/web3.js';
import { useMutation, useQuery } from '@tanstack/react-query';
import { useMemo } from 'react';
import toast from 'react-hot-toast';
import { useCluster } from '../cluster/cluster-data-access';
import { useAnchorProvider } from '../solana/solana-provider';
import { useTransactionToast } from '../ui/ui-layout';

export function useSimpleTodoListProgram() {
  const { connection } = useConnection();
  const { cluster } = useCluster();
  const transactionToast = useTransactionToast();
  const provider = useAnchorProvider();
  const programId = useMemo(
    () => getSimpleTodoListProgramId(cluster.network as Cluster),
    [cluster]
  );
  const program = new Program(SimpleTodoListIDL, programId, provider);

  const accounts = useQuery({
    queryKey: ['simple-todo-list', 'all', { cluster }],
    queryFn: () => program.account.simpleTodoList.all(),
  });

  const getProgramAccount = useQuery({
    queryKey: ['get-program-account', { cluster }],
    queryFn: () => connection.getParsedAccountInfo(programId),
  });

  const initialize = useMutation({
    mutationKey: ['simple-todo-list', 'initialize', { cluster }],
    mutationFn: (keypair: Keypair) =>
      program.methods
        .initialize()
        .accounts({ simpleTodoList: keypair.publicKey })
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

export function useSimpleTodoListProgramAccount({
  account,
}: {
  account: PublicKey;
}) {
  const { cluster } = useCluster();
  const transactionToast = useTransactionToast();
  const { program, accounts } = useSimpleTodoListProgram();

  const accountQuery = useQuery({
    queryKey: ['simple-todo-list', 'fetch', { cluster, account }],
    queryFn: () => program.account.simpleTodoList.fetch(account),
  });

  const closeMutation = useMutation({
    mutationKey: ['simple-todo-list', 'close', { cluster, account }],
    mutationFn: () =>
      program.methods.close().accounts({ simpleTodoList: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accounts.refetch();
    },
  });

  const decrementMutation = useMutation({
    mutationKey: ['simple-todo-list', 'decrement', { cluster, account }],
    mutationFn: () =>
      program.methods.decrement().accounts({ simpleTodoList: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accountQuery.refetch();
    },
  });

  const incrementMutation = useMutation({
    mutationKey: ['simple-todo-list', 'increment', { cluster, account }],
    mutationFn: () =>
      program.methods.increment().accounts({ simpleTodoList: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accountQuery.refetch();
    },
  });

  const setMutation = useMutation({
    mutationKey: ['simple-todo-list', 'set', { cluster, account }],
    mutationFn: (value: number) =>
      program.methods.set(value).accounts({ simpleTodoList: account }).rpc(),
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
