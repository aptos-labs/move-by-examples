import { useParams } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { useEffect } from "react";

import { BannerSection } from "@/pages/Mint/components/BannerSection";
import { HeroSection } from "@/pages/Mint/components/HeroSection";
import { StatsSection } from "@/pages/Mint/components/StatsSection";
import { OurStorySection } from "@/pages/Mint/components/OurStorySection";
import { HowToMintSection } from "@/pages/Mint/components/HowToMintSection";
import { OurTeamSection } from "@/pages/Mint/components/OurTeamSection";
import { FAQSection } from "@/pages/Mint/components/FAQSection";
import { Socials } from "@/pages/Mint/components/Socials";
import { useGetCollectionData } from "@/hooks/useGetCollectionData";
import { Header } from "@/components/Header";

export function Mint() {
  const { collectionAddress } = useParams();
  const { data, isLoading } = useGetCollectionData(collectionAddress);

  const queryClient = useQueryClient();
  const { account } = useWallet();
  useEffect(() => {
    queryClient.invalidateQueries();
  }, [account, queryClient]);

  if (isLoading) {
    return (
      <div className="text-center p-8">
        <h1 className="title-md">Loading...</h1>
      </div>
    );
  }

  return (
    <>
      <Header />
      <div style={{ overflow: "hidden" }} className="overflow-hidden">
        <main className="flex flex-col gap-10 md:gap-16 mt-6">
          <HeroSection collectionAddress={collectionAddress} />
          <StatsSection collectionAddress={collectionAddress} />
          <OurStorySection />
          <HowToMintSection />
          <BannerSection />
          <OurTeamSection />
          <FAQSection />
        </main>

        <footer className="footer-container px-4 pb-6 w-full max-w-screen-xl mx-auto mt-6 md:mt-16 flex items-center justify-between">
          <p>{data?.collection.collection_name}</p>
          <Socials />
        </footer>
      </div>
    </>
  );
}
