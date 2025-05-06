import {
  getAllListingObjectAddresses,
  getAptogotchi,
  getListingObjectAndSeller,
  getListingObjectPrice,
} from "@/utils/aptos";
import { useEffect, useState } from "react";
import { useGetAllSellers } from "./useGetAllSellers";
import { ListedAptogotchiWithTraits } from "@/utils/types";

export const useGetAllListedNfts = () => {
  const sellers = useGetAllSellers();
  const [nfts, setNfts] = useState<ListedAptogotchiWithTraits[]>();
  useEffect(() => {
    if (!sellers) return;
    (async () => {
      const aptogotchiWithTraits = [];
      for (const seller of sellers) {
        const listingObjectAddresses = await getAllListingObjectAddresses(
          seller
        );
        for (const listingObjectAddress of listingObjectAddresses) {
          const [nftAddress, sellerAddress] = await getListingObjectAndSeller(
            listingObjectAddress
          );
          const price = await getListingObjectPrice(listingObjectAddress);
          const [name, traits] = await getAptogotchi(nftAddress);
          aptogotchiWithTraits.push({
            name,
            address: nftAddress,
            ...traits,
            listing_object_address: listingObjectAddress,
            seller_address: sellerAddress,
            price,
          });
        }
      }
      setNfts(aptogotchiWithTraits);
    })();
  }, [sellers]);
  return nfts;
};
