import { ABI } from "@repo/contract-abis/src/message_board_abi";
import { createSurfClient } from "@thalalabs/surf";
import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";
import { NetworkInfo } from "@aptos-labs/wallet-adapter-react";

export const aptosClient = (network?: NetworkInfo | null) => {
  if (network?.name === Network.DEVNET) {
    return DEVNET_CLIENT;
  } else if (network?.name === Network.TESTNET) {
    return TESTNET_CLIENT;
  } else if (network?.name === Network.MAINNET) {
    throw new Error("Please use devnet or testnet for testing");
  } else {
    const CUSTOM_CONFIG = new AptosConfig({
      network: Network.CUSTOM,
      fullnode: network?.url,
    });
    return new Aptos(CUSTOM_CONFIG);
  }
};

export const surfClient = (network?: NetworkInfo | null) => {
  return createSurfClient(aptosClient(network)).useABI(ABI);
};

// Devnet client
export const DEVNET_CONFIG = new AptosConfig({
  network: Network.DEVNET,
});
export const DEVNET_CLIENT = new Aptos(DEVNET_CONFIG);

// Testnet client
export const TESTNET_CONFIG = new AptosConfig({ network: Network.TESTNET });
export const TESTNET_CLIENT = new Aptos(TESTNET_CONFIG);

export const isSendableNetwork = (
  connected: boolean,
  networkName?: string
): boolean => {
  return connected && !isMainnet(connected, networkName);
};

export const isMainnet = (
  connected: boolean,
  networkName?: string
): boolean => {
  return connected && networkName === Network.MAINNET;
};
