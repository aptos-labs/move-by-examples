import {
  Account,
  Aptos,
  AptosConfig,
  Ed25519PrivateKey,
  Network,
} from "@aptos-labs/ts-sdk";
import { createSurfClient } from "@thalalabs/surf";
import { ABI } from "@repo/contract-abis/src/message_board_abi";

export const client = createSurfClient(
  new Aptos(
    new AptosConfig({
      network: Network.TESTNET,
    }),
  ),
).useABI(ABI);

export const account = Account.fromPrivateKey({
  privateKey: new Ed25519PrivateKey("to_fill"),
});
