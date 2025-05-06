import { List } from "@/components/List";
import { useGetListedNftsBySeller } from "@/hooks/useGetListedNftsBySeller";
import { useGetNftsByOwner } from "@/hooks/useGetNftsByOwner";
import {
  Box,
  Button,
  Divider,
  HStack,
  SimpleGrid,
  Text,
} from "@chakra-ui/react";
import { NftCard } from "./NftCard";

type Props = {
  address: string;
};

export const Portfolio = ({ address }: Props) => {
  const nftsInWallet = useGetNftsByOwner(address);
  const nftsListed = useGetListedNftsBySeller(address);

  const goToMint = () => {
    window.location.href = "/mint";
  };

  return (
    <Box>
      <HStack
        marginTop={4}
        marginBottom={12}
        justifyContent="center"
        flexDirection="column"
      >
        <Text fontSize="xl" fontWeight="bold" textAlign="center" marginY={4}>
          My NFTs
        </Text>
        {nftsInWallet && nftsInWallet.length > 0 ? (
          <SimpleGrid spacing={10} columns={3}>
            {nftsInWallet.map((nft) => {
              return (
                <NftCard nft={nft} key={nft.address}>
                  <List nftTokenObjectAddr={nft.address} />
                </NftCard>
              );
            })}
          </SimpleGrid>
        ) : (
          <Button onClick={goToMint}>Mint a Aptogotchi NFT</Button>
        )}
      </HStack>
      <Divider />
      <HStack marginY={12} justifyContent="center" flexDirection="column">
        <Text fontSize="xl" fontWeight="bold" textAlign="center" marginY={4}>
          My Listed NFTs
        </Text>
        {nftsListed &&
          (nftsListed.length > 0 ? (
            <SimpleGrid spacing={10} columns={3}>
              {nftsListed.map((nft) => {
                return <NftCard key={nft.address} nft={nft} />;
              })}
            </SimpleGrid>
          ) : (
            <Text size="md">No NFT listed</Text>
          ))}
      </HStack>
    </Box>
  );
};
