"use client";

import {
  useWallet,
  WalletReadyState,
  Wallet,
  isRedirectable,
  WalletName,
} from "@aptos-labs/wallet-adapter-react";
import { Button, Text } from "@chakra-ui/react";

export const WalletButtons = () => {
  const { wallets, connected, disconnect, isLoading } = useWallet();

  if (connected) {
    return <Button onClick={disconnect}>Disconnect</Button>;
  }

  if (isLoading || !wallets || !wallets[0]) {
    return <Text>Loading...</Text>;
  }

  return <WalletView wallet={wallets[0] as Wallet} />;
};

const WalletView = ({ wallet }: { wallet: Wallet }) => {
  const { connect } = useWallet();
  const isWalletReady =
    wallet.readyState === WalletReadyState.Installed ||
    wallet.readyState === WalletReadyState.Loadable;
  const mobileSupport = wallet.deeplinkProvider;

  const onWalletConnectRequest = async (walletName: WalletName) => {
    try {
      connect(walletName);
    } catch (error) {
      console.warn(error);
      window.alert("Failed to connect wallet");
    }
  };

  /**
   * If we are on a mobile browser, adapter checks whether a wallet has a `deeplinkProvider` property
   * a. If it does, on connect it should redirect the user to the app by using the wallet's deeplink url
   * b. If it does not, up to the dapp to choose on the UI, but can simply disable the button
   * c. If we are already in a in-app browser, we don't want to redirect anywhere, so connect should work as expected in the mobile app.
   *
   * !isWalletReady - ignore installed/sdk wallets that don't rely on window injection
   * isRedirectable() - are we on mobile AND not in an in-app browser
   * mobileSupport - does wallet have deeplinkProvider property? i.e does it support a mobile app
   */
  if (!isWalletReady && isRedirectable()) {
    // wallet has mobile app
    if (mobileSupport) {
      return (
        <Button onClick={() => onWalletConnectRequest(wallet.name)}>
          Connect Wallet
        </Button>
      );
    }
    // wallet does not have mobile app
    return <Button isDisabled={true}>Connect Wallet - Desktop Only</Button>;
  } else {
    // desktop
    return (
      <Button
        isDisabled={!isWalletReady}
        onClick={() => onWalletConnectRequest(wallet.name)}
      >
        Connect Wallet
      </Button>
    );
  }
};
