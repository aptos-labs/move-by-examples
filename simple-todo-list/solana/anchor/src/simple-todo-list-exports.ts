// Here we export some useful types and functions for interacting with the Anchor program.
import { Cluster, PublicKey } from '@solana/web3.js';
import type { SimpleTodoList } from '../target/types/simple_todo_list';
import { IDL as SimpleTodoListIDL } from '../target/types/simple_todo_list';

// Re-export the generated IDL and type
export { SimpleTodoList, SimpleTodoListIDL };

// After updating your program ID (e.g. after running `anchor keys sync`) update the value below.
export const SIMPLE_TODO_LIST_PROGRAM_ID = new PublicKey(
  'AoFCssRtKUgXfhwb2T4F3jLenCZaSxmkAwrZAL9SQB9G'
);

// This is a helper function to get the program ID for the SimpleTodoList program depending on the cluster.
export function getSimpleTodoListProgramId(cluster: Cluster) {
  switch (cluster) {
    case 'devnet':
    case 'testnet':
    case 'mainnet-beta':
    default:
      return SIMPLE_TODO_LIST_PROGRAM_ID;
  }
}
