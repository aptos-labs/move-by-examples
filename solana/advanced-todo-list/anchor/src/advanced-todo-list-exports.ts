// Here we export some useful types and functions for interacting with the Anchor program.
import { Cluster, PublicKey } from '@solana/web3.js';
import type { AdvancedTodoList } from '../target/types/advanced_todo_list';
import { IDL as AdvancedTodoListIDL } from '../target/types/advanced_todo_list';

// Re-export the generated IDL and type
export { AdvancedTodoList, AdvancedTodoListIDL };

// After updating your program ID (e.g. after running `anchor keys sync`) update the value below.
export const ADVANCED_TODO_LIST_PROGRAM_ID = new PublicKey(
  'CpdzsbyuX6ZpS37LqtN5qL4SXSz2LXzz7mckgYQupJ3V'
);

// This is a helper function to get the program ID for the AdvancedTodoList program depending on the cluster.
export function getAdvancedTodoListProgramId(cluster: Cluster) {
  switch (cluster) {
    case 'devnet':
    case 'testnet':
    case 'mainnet-beta':
    default:
      return ADVANCED_TODO_LIST_PROGRAM_ID;
  }
}
