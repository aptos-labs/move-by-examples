"use client";

import { AllNfts } from "@/components/AllNfts";
import { ListedNfts } from "@/components/ListedNfts";
import { HStack, Heading, Radio, RadioGroup } from "@chakra-ui/react";
import { useState } from "react";

export default function Page() {
  const [radioValue, setRadioValue] = useState<"All NFTs" | "Listed NFTs">(
    "All NFTs"
  );

  return (
    <HStack flexDirection="column">
      <Heading margin={4} textAlign="center">
        Aptogotchi NFTs
      </Heading>
      <RadioGroup defaultValue="All NFTs" margin={4}>
        <HStack justifyContent="center">
          <Radio
            value="All NFTs"
            onChange={() => {
              setRadioValue("All NFTs");
            }}
          >
            All NFTs
          </Radio>
          <Radio
            value="Listed NFTs"
            onChange={() => {
              setRadioValue("Listed NFTs");
            }}
          >
            Listed NFTs
          </Radio>
        </HStack>
      </RadioGroup>
      {radioValue === "Listed NFTs" ? <ListedNfts /> : <AllNfts />}
    </HStack>
  );
}
