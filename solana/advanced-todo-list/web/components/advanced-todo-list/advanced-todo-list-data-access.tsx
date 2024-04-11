'use client';

import {
  AdvancedTodoListIDL,
  getAdvancedTodoListProgramId,
} from '@advanced-todo-list/anchor';
import { Program } from '@coral-xyz/anchor';
import { useConnection } from '@solana/wallet-adapter-react';
import { Cluster, Keypair, PublicKey } from '@solana/web3.js';
import { useMutation, useQuery } from '@tanstack/react-query';
import { useMemo } from 'react';
import toast from 'react-hot-toast';
import { useCluster } from '../cluster/cluster-data-access';
import { useAnchorProvider } from '../solana/solana-provider';
import { useTransactionToast } from '../ui/ui-layout';

export function useAdvancedTodoListProgram() {
  const { connection } = useConnection();
  const { cluster } = useCluster();
  const transactionToast = useTransactionToast();
  const provider = useAnchorProvider();
  const programId = useMemo(
    () => getAdvancedTodoListProgramId(cluster.network as Cluster),
    [cluster]
  );
  const program = new Program(AdvancedTodoListIDL, programId, provider);

  const accounts = useQuery({
    queryKey: ['advanced-todo-list', 'all', { cluster }],
    queryFn: () => program.account.advancedTodoList.all(),
  });

  const getProgramAccount = useQuery({
    queryKey: ['get-program-account', { cluster }],
    queryFn: () => connection.getParsedAccountInfo(programId),
  });

  const initialize = useMutation({
    mutationKey: ['advanced-todo-list', 'initialize', { cluster }],
    mutationFn: (keypair: Keypair) =>
      program.methods
        .initialize()
        .accounts({ advancedTodoList: keypair.publicKey })
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

export function useAdvancedTodoListProgramAccount({
  account,
}: {
  account: PublicKey;
}) {
  const { cluster } = useCluster();
  const transactionToast = useTransactionToast();
  const { program, accounts } = useAdvancedTodoListProgram();

  const accountQuery = useQuery({
    queryKey: ['advanced-todo-list', 'fetch', { cluster, account }],
    queryFn: () => program.account.advancedTodoList.fetch(account),
  });

  const closeMutation = useMutation({
    mutationKey: ['advanced-todo-list', 'close', { cluster, account }],
    mutationFn: () =>
      program.methods.close().accounts({ advancedTodoList: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accounts.refetch();
    },
  });

  const decrementMutation = useMutation({
    mutationKey: ['advanced-todo-list', 'decrement', { cluster, account }],
    mutationFn: () =>
      program.methods.decrement().accounts({ advancedTodoList: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accountQuery.refetch();
    },
  });

  const incrementMutation = useMutation({
    mutationKey: ['advanced-todo-list', 'increment', { cluster, account }],
    mutationFn: () =>
      program.methods.increment().accounts({ advancedTodoList: account }).rpc(),
    onSuccess: (tx) => {
      transactionToast(tx);
      return accountQuery.refetch();
    },
  });

  const setMutation = useMutation({
    mutationKey: ['advanced-todo-list', 'set', { cluster, account }],
    mutationFn: (value: number) =>
      program.methods.set(value).accounts({ advancedTodoList: account }).rpc(),
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
