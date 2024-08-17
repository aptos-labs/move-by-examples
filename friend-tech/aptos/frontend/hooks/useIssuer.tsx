import { useState, useEffect } from "react";

import { surfClient } from "@/utils/aptosClient";
import { Issuer } from "@/utils/types";

// This call can be pretty expensive when fetching a big number of assets,
// therefore it is not recommended to use it in production
export function useGetIssuers() {
  const [issuers, setIssuers] = useState<Issuer[]>([]);

  useEffect(() => {
    getRegistry().then((issuerObjects) => {
      getIssuers(issuerObjects).then((issuers) => {
        setIssuers(issuers);
      });
    });
  }, []);

  return issuers;
}

export function useGetIssuer(issuerAddress?: string) {
  const [issuer, setIssuer] = useState<Issuer>();

  useEffect(() => {
    if (!issuerAddress) {
      return;
    }
    getIssuerObject(issuerAddress as `0x${string}`).then((issuerObject) => {
      getIssuer(issuerObject).then((result) => {
        setIssuer(result);
      });
    });
  }, [issuerAddress]);

  return issuer;
}

export function useHasIssuedShare(issuerAddress?: string) {
  const [hasIssuedShare, setHasIssuedShare] = useState<boolean>(false);

  useEffect(() => {
    if (!issuerAddress) {
      return;
    }
    surfClient()
      .view.has_issued_share({
        typeArguments: [],
        functionArguments: [issuerAddress as `0x${string}`],
      })
      .then((result) => {
        setHasIssuedShare(result[0]);
      });
  }, [issuerAddress]);

  return hasIssuedShare;
}

const getRegistry = async () => {
  return (
    await surfClient().view.get_issuer_registry({
      typeArguments: [],
      functionArguments: [],
    })
  )[0] as [{ inner: `0x${string}` }];
};

const getIssuerObject = async (issuerAddress: `0x${string}`) => {
  return (
    await surfClient().view.get_issuer_obj({
      typeArguments: [],
      functionArguments: [issuerAddress],
    })
  )[0] as { inner: `0x${string}` };
};

const getIssuer = async (issuerObject: { inner: `0x${string}` }) => {
  return await surfClient()
    .view.get_issuer({
      typeArguments: [],
      functionArguments: [issuerObject.inner],
    })
    .then((issuer) => {
      return {
        issuerObjectAddress: issuerObject.inner,
        issuerAddress: issuer[0],
        username: issuer[1],
        totalIssuedShares: parseInt(issuer[2]),
      };
    });
};

const getIssuers = async (issuerObjects: [{ inner: `0x${string}` }]) => {
  return await Promise.all(issuerObjects.map((issuerObject: { inner: `0x${string}` }) => getIssuer(issuerObject)));
};
