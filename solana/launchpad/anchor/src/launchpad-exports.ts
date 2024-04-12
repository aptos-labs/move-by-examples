// Here we export some useful types and functions for interacting with the Anchor program.
import { Cluster, PublicKey } from '@solana/web3.js';
import type { Launchpad } from '../target/types/launchpad';
import { IDL as LaunchpadIDL } from '../target/types/launchpad';

// Re-export the generated IDL and type
export { Launchpad, LaunchpadIDL };

// After updating your program ID (e.g. after running `anchor keys sync`) update the value below.
export const LAUNCHPAD_PROGRAM_ID = new PublicKey(
  '7kUij7HeYodZGUGB1d1TQpHC3gxUqf4t6NQBf3QjVpru'
);

// This is a helper function to get the program ID for the Launchpad program depending on the cluster.
export function getLaunchpadProgramId(cluster: Cluster) {
  switch (cluster) {
    case 'devnet':
    case 'testnet':
    case 'mainnet-beta':
    default:
      return LAUNCHPAD_PROGRAM_ID;
  }
}
