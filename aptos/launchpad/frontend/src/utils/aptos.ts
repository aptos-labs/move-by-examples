import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";

const config = new AptosConfig({
  network: Network.TESTNET,
});
export const aptosClient = new Aptos(config);
