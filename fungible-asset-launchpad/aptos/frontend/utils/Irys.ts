import { WebIrys } from "@irys/sdk";
import { WalletContextState } from "@aptos-labs/wallet-adapter-react";
import { accountAPTBalance } from "@/view-functions/accountBalance";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const getWebIrys = async (aptosWallet: any) => {
  const network = "devnet"; // Irys network
  const token = "aptos";
  const rpcUrl = "testnet"; // Aptos network "mainnet" || "testnet"
  const wallet = { rpcUrl: rpcUrl, name: "aptos", provider: aptosWallet };
  const webIrys = new WebIrys({ network, token, wallet });
  await webIrys.ready();
  return webIrys;
};

/* TODO, the steps would be:
1. estimate the gas cost based on the data size https://docs.irys.xyz/developer-docs/irys-sdk/api/getPrice
2. check the wallet balance on the irys node: irys.getLoadedBalance()
3. if balance is enough, then upload without funding
4. if balance is not enough,  check the payer balance
5. if payer balance > the amount based on the estimation, fund the irys node irys.fund, then upload
6. if payer balance < the amount, replenish the payer balance*/

export const checkIfFund = async (aptosWallet: WalletContextState, fileSize: number) => {
  // 1. estimate the gas cost based on the data size https://docs.irys.xyz/developer-docs/irys-sdk/api/getPrice
  const webIrys = await getWebIrys(aptosWallet);
  const costToUpload = await webIrys.getPrice(fileSize);
  // 2. check the wallet balance on the irys node: irys.getLoadedBalance()
  const irysBalance = await webIrys.getLoadedBalance();
  // 3. if balance is enough, then upload without funding
  if (irysBalance.toNumber() > costToUpload.toNumber()) {
    return true;
  }
  // 4. if balance is not enough,  check the payer balance
  const currentAccountAddress = await aptosWallet.account!.address;

  const currentAccountBalance = await accountAPTBalance({ accountAddress: currentAccountAddress });

  // 5. if payer balance > the amount based on the estimation, fund the irys node irys.fund, then upload
  if (currentAccountBalance > costToUpload.toNumber()) {
    try {
      await fundNode(aptosWallet, costToUpload.toNumber());
      return true;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      throw new Error(`Error funding node ${error}`);
    }
  }
  // 6. if payer balance < the amount, replenish the payer balance*/
  return false;
};

export const fundNode = async (aptosWallet: WalletContextState, amount?: number) => {
  const webIrys = await getWebIrys(aptosWallet);

  try {
    const fundTx = await webIrys.fund(amount ?? 1000000);
    console.log(`Successfully funded ${webIrys.utils.fromAtomic(fundTx.quantity)} ${webIrys.token}`);
    return true;
  } catch (e) {
    throw new Error(`Error uploading data ${e}`);
  }
};

export const uploadFile = async (aptosWallet: WalletContextState, fileToUpload: File): Promise<string> => {
  const webIrys = await getWebIrys(aptosWallet);
  try {
    const receipt = await webIrys.uploadFile(fileToUpload, { tags: [] });
    return `https://gateway.irys.xyz/${receipt.id}`;
  } catch (e) {
    throw new Error(`Error uploading file ${e}`);
  }
};
