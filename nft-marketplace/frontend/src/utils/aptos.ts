import { Aptos, AptosConfig, Network, Account } from "@aptos-labs/ts-sdk";
import { Aptogotchi, AptogotchiTraits } from "./types";
import { ABI } from "./abi";

export const APTOGOTCHI_CONTRACT_ADDRESS =
  "0x497c93ccd5d3c3e24a8226d320ecc9c69697c0dad5e1f195553d7eaa1140e91f";
export const COLLECTION_ID =
  "0xfce62045f3ac19160c1e88662682ccb6ef1173eba82638b8bae172cc83d8e8b8";
export const COLLECTION_CREATOR_ADDRESS =
  "0x714319fa1946db285254e3c7c75a9aac05277200e59429dd1f80f25272910d9c";
export const COLLECTION_NAME = "Aptogotchi Collection";

export const APT = "0x1::aptos_coin::AptosCoin";
export const APT_UNIT = 100_000_000;

const config = new AptosConfig({
  network: Network.TESTNET,
});
export const aptos = new Aptos(config);

export const getAptogotchi = async (
  aptogotchiObjectAddr: string
): Promise<[string, AptogotchiTraits]> => {
  console.log("aptogotchiObjectAddr", aptogotchiObjectAddr);
  const aptogotchi = await aptos.view({
    payload: {
      function: `${APTOGOTCHI_CONTRACT_ADDRESS}::main::get_aptogotchi`,
      typeArguments: [],
      functionArguments: [aptogotchiObjectAddr],
    },
  });
  console.log(aptogotchi);
  return [aptogotchi[0] as string, aptogotchi[1] as AptogotchiTraits];
};

export const mintAptogotchi = async (
  sender: Account,
  name: string,
  body: number,
  ear: number,
  face: number
) => {
  const rawTxn = await aptos.transaction.build.simple({
    sender: sender.accountAddress,
    data: {
      function: `${APTOGOTCHI_CONTRACT_ADDRESS}::main::create_aptogotchi`,
      functionArguments: [name, body, ear, face],
    },
  });
  const pendingTxn = await aptos.signAndSubmitTransaction({
    signer: sender,
    transaction: rawTxn,
  });
  const response = await aptos.waitForTransaction({
    transactionHash: pendingTxn.hash,
  });
  console.log("minted aptogotchi. - ", response.hash);
};

export const getAptBalance = async (addr: string) => {
  const result = await aptos.getAccountCoinAmount({
    accountAddress: addr,
    coinType: APT,
  });

  console.log("APT balance", result);
  return result;
};

export const getCollection = async () => {
  // const collection = await aptos.getCollectionDataByCollectionId({
  //   collectionId: COLLECTION_ID,
  // });
  const collection = await aptos.getCollectionData({
    collectionName: COLLECTION_NAME,
    creatorAddress: COLLECTION_CREATOR_ADDRESS,
  });
  console.log("collection", collection);
  return collection;
};

export const getUserOwnedAptogotchis = async (ownerAddr: string) => {
  const result = await aptos.getAccountOwnedTokensFromCollectionAddress({
    accountAddress: ownerAddr,
    collectionAddress: COLLECTION_ID,
  });

  console.log("my aptogotchis", result);
  return result;
};

export const getAllAptogotchis = async () => {
  const result: {
    current_token_datas_v2: Aptogotchi[];
  } = await aptos.queryIndexer({
    query: {
      query: `
        query MyQuery($collectionId: String) {
          current_token_datas_v2(
            where: {collection_id: {_eq: $collectionId}}
          ) {
            name: token_name
            address: token_data_id
          }
        }
      `,
      variables: { collectionId: COLLECTION_ID },
    },
  });

  return result.current_token_datas_v2;
};

export const listAptogotchi = async (
  sender: Account,
  aptogotchiObjectAddr: string
) => {
  const rawTxn = await aptos.transaction.build.simple({
    sender: sender.accountAddress,
    data: {
      function: `${ABI.address}::marketplace::list_with_fixed_price`,
      typeArguments: [APT],
      functionArguments: [aptogotchiObjectAddr, 10],
    },
  });
  const pendingTxn = await aptos.signAndSubmitTransaction({
    signer: sender,
    transaction: rawTxn,
  });
  const response = await aptos.waitForTransaction({
    transactionHash: pendingTxn.hash,
  });
  console.log("listed aptogotchi. - ", response.hash);
};

export const buyAptogotchi = async (
  sender: Account,
  listingObjectAddr: string
) => {
  const rawTxn = await aptos.transaction.build.simple({
    sender: sender.accountAddress,
    data: {
      function: `${ABI.address}::marketplace::purchase`,
      typeArguments: [APT],
      functionArguments: [listingObjectAddr],
    },
  });
  const pendingTxn = await aptos.signAndSubmitTransaction({
    signer: sender,
    transaction: rawTxn,
  });
  const response = await aptos.waitForTransaction({
    transactionHash: pendingTxn.hash,
  });
  console.log("bought aptogotchi. - ", response.hash);
};

export const getAllListingObjectAddresses = async (sellerAddr: string) => {
  const allListings: [string[]] = await aptos.view({
    payload: {
      function: `${ABI.address}::marketplace::get_seller_listings`,
      typeArguments: [],
      functionArguments: [sellerAddr],
    },
  });
  console.log("all listings", allListings);
  return allListings[0];
};

export const getAllSellers = async () => {
  const allSellers: [string[]] = await aptos.view({
    payload: {
      function: `${ABI.address}::marketplace::get_sellers`,
      typeArguments: [],
      functionArguments: [],
    },
  });
  console.log("all sellers", allSellers);
  return allSellers[0];
};

export const getListingObjectAndSeller = async (
  listingObjectAddr: string
): Promise<[string, string]> => {
  const listingObjectAndSeller = await aptos.view({
    payload: {
      function: `${ABI.address}::marketplace::listing`,
      typeArguments: [],
      functionArguments: [listingObjectAddr],
    },
  });
  console.log("listing object and seller", listingObjectAndSeller);
  return [
    // @ts-ignore
    listingObjectAndSeller[0]["inner"] as string,
    listingObjectAndSeller[1] as string,
  ];
};

export const getListingObjectPrice = async (
  listingObjectAddr: string
): Promise<number> => {
  const listingObjectPrice = await aptos.view({
    payload: {
      function: `${ABI.address}::marketplace::price`,
      typeArguments: [APT],
      functionArguments: [listingObjectAddr],
    },
  });
  console.log("listing object price", JSON.stringify(listingObjectPrice));
  // @ts-ignore
  return (listingObjectPrice[0]["vec"] as number) / APT_UNIT;
};
