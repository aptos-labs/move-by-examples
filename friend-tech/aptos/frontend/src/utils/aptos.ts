import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";
import { createSurfClient } from "@thalalabs/surf";
import { ABI } from "./abi";

const config = new AptosConfig({
  network: Network.TESTNET,
});
export const aptosClient = new Aptos(config);
export const surfClient = createSurfClient(aptosClient).useABI(ABI);
