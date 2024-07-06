import { ABI } from "@repo/contract-abis/src/message_board_abi";
import { createSurfClient } from "@thalalabs/surf";
import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";

export const NETWORK_NAME = Network.TESTNET;

export const aptosClient = () => {
  return TESTNET_CLIENT;
};

export const surfClient = () => {
  return createSurfClient(aptosClient()).useABI(ABI);
};

// Testnet client
export const TESTNET_CONFIG = new AptosConfig({ network: Network.TESTNET });
export const TESTNET_CLIENT = new Aptos(TESTNET_CONFIG);

export const isSendableNetwork = (
  connected: boolean,
  networkName?: string,
): boolean => {
  return connected && isTestnet(connected, networkName);
};

export const isTestnet = (
  connected: boolean,
  networkName?: string,
): boolean => {
  return connected && networkName === Network.TESTNET;
};
