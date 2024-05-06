// Here we export some useful types and functions for interacting with the Anchor program.
import { Cluster, PublicKey } from '@solana/web3.js';
import type { FriendTech } from '../target/types/friend_tech';
import { IDL as FriendTechIDL } from '../target/types/friend_tech';

// Re-export the generated IDL and type
export { FriendTech, FriendTechIDL };

// After updating your program ID (e.g. after running `anchor keys sync`) update the value below.
export const FRIEND_TECH_PROGRAM_ID = new PublicKey(
  'GcdUTgTLJ5TFQpD5r2Da8ogVnSCr8XBpmUxYdU2nzdK'
);

// This is a helper function to get the program ID for the FriendTech program depending on the cluster.
export function getFriendTechProgramId(cluster: Cluster) {
  switch (cluster) {
    case 'devnet':
    case 'testnet':
    case 'mainnet-beta':
    default:
      return FRIEND_TECH_PROGRAM_ID;
  }
}
