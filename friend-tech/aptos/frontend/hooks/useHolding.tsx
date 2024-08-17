import { useState, useEffect } from "react";

import { surfClient } from "@/utils/aptosClient";
import { Holding } from "@/utils/types";

export function useGetHoldings(userAddress?: string) {
  const [holdings, setHoldings] = useState<Holding[]>();

  useEffect(() => {
    if (!userAddress) {
      return;
    }
    getUserObject(userAddress as `0x${string}`).then((userObject) => {
      getHoldingObjects(userObject).then((holdingObjects) => {
        getHoldings(holdingObjects).then((result) => {
          setHoldings(result);
        });
      });
    });
  }, [userAddress]);

  return holdings;
}

export function useGetHolding(issuerAddress?: string, holderAddress?: string) {
  const [holding, setHolding] = useState<Holding>();

  useEffect(() => {
    if (!issuerAddress || !holderAddress) {
      return;
    }
    getHoldingObject(issuerAddress as `0x${string}`, holderAddress as `0x${string}`).then((holdingObject) => {
      getHolding(holdingObject).then((result) => {
        setHolding(result);
      });
    });
  }, [issuerAddress, holderAddress]);

  return holding;
}

export function useGetIssuerObjectAddress(issuerAddress?: string) {
  const [issuerObjectAddress, setIssuerObjectAddress] = useState<`0x${string}`>();

  useEffect(() => {
    if (!issuerAddress) {
      return;
    }
    surfClient()
      .view.get_issuer_obj({
        typeArguments: [],
        functionArguments: [issuerAddress as `0x${string}`],
      })
      .then((result) => {
        setIssuerObjectAddress((result[0] as { inner: `0x${string}` }).inner);
      });
  }, [issuerAddress]);

  return issuerObjectAddress;
}

const getUserObject = async (userAddress: `0x${string}`) => {
  return (
    await surfClient().view.get_user_obj({
      typeArguments: [],
      functionArguments: [userAddress],
    })
  )[0] as { inner: `0x${string}` };
};

const getHoldingObject = async (issuerAddress: `0x${string}`, holderAddress: `0x${string}`) => {
  return (
    await surfClient().view.get_holding_obj({
      typeArguments: [],
      functionArguments: [issuerAddress, holderAddress],
    })
  )[0] as { inner: `0x${string}` };
};

const getHoldingObjects = async (userObject: { inner: `0x${string}` }) => {
  return (
    await surfClient().view.get_user_holdings({
      typeArguments: [],
      functionArguments: [userObject.inner],
    })
  )[0] as { inner: `0x${string}` }[];
};

const getHolding = async (holdingObject: { inner: `0x${string}` }) => {
  return await surfClient()
    .view.get_holding({
      typeArguments: [],
      functionArguments: [holdingObject.inner],
    })
    .then((holding) => {
      return {
        issuer: holding[0],
        holder: holding[1],
        shares: parseInt(holding[2]),
      };
    });
};

const getHoldings = async (holdingObjects: { inner: `0x${string}` }[]) => {
  return await Promise.all(holdingObjects.map((holdingObject: { inner: `0x${string}` }) => getHolding(holdingObject)));
};
