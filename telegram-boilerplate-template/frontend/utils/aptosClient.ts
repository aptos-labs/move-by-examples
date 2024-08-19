import { Aptos, AptosConfig } from "@aptos-labs/ts-sdk";
import { createSurfClient } from "@thalalabs/surf";

import { NETWORK } from "@/constants";
import { ABI } from "@/utils/abi";

const aptos = new Aptos(new AptosConfig({ network: NETWORK }));
const surf = createSurfClient(aptos).useABI(ABI);

// Reuse same Aptos instance to utilize cookie based sticky routing
export function aptosClient() {
  return aptos;
}

// Reuse same Surf instance to utilize cookie based sticky routing
export function surfClient() {
  return surf;
}
