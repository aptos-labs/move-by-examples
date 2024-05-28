import { useGetAllNfts } from "@/hooks/useGetAllNfts";
import { SimpleGrid } from "@chakra-ui/react";
import { NftCard } from "./NftCard";

export const AllNfts = () => {
  const allNfts = useGetAllNfts();
  return allNfts ? (
    <SimpleGrid spacing={10} columns={3}>
      {allNfts.map((nft) => {
        return <NftCard nft={nft} key={nft.address} />;
      })}
    </SimpleGrid>
  ) : (
    <></>
  );
};
