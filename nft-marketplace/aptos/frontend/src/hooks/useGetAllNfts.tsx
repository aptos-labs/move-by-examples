import { getAllAptogotchis, getAptogotchi } from "@/utils/aptos";
import { AptogotchiWithTraits } from "@/utils/types";
import { useEffect, useState } from "react";

export const useGetAllNfts = () => {
  const [nfts, setNfts] = useState<AptogotchiWithTraits[]>();
  useEffect(() => {
    getAllAptogotchis().then(async (res) => {
      const aptogotchiWithTraits = [];
      for (const aptogotchi of res) {
        const [_, traits] = await getAptogotchi(aptogotchi.address);
        aptogotchiWithTraits.push({
          ...aptogotchi,
          ...traits,
        });
      }
      setNfts(aptogotchiWithTraits);
    });
  }, []);
  return nfts;
};
