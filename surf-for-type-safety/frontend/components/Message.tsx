import { useEffect, useState } from "react";

import { surfClient } from "@/utils/aptosClient";
import { LabelValueGrid } from "@/components/LabelValueGrid";

export function Message() {
  const [booleanContent, setBooleanContent] = useState<boolean>();
  const [stringContent, setStringContent] = useState<string>();
  const [numberContent, setNumberContent] = useState<number>();
  const [addressContent, setAddressContent] = useState<string>();
  const [objectContent, setObjectContent] = useState<{ inner: `0x${string}` }>();
  const [vectorContent, setVectorContent] = useState<string[]>();
  const [optionalBooleanContent, setOptionalBooleanContent] = useState<{ vec: [boolean] | [] }>();
  const [optionalStringContent, setOptionalStringContent] = useState<{ vec: [string] | [] }>();
  const [optionalNumberContent, setOptionalNumberContent] = useState<{ vec: [string] | [] }>();
  const [optionalAddressContent, setOptionalAddressContent] = useState<{ vec: [`0x${string}`] | [] }>();
  const [optionalObjectContent, setOptionalObjectContent] = useState<{ vec: [{ inner: `0x${string}` }] | [] }>();
  const [optionalVectorContent, setOptionalVectorContent] = useState<{ vec: [string[]] | [] }>();

  useEffect(() => {
    surfClient()
      .view.get_message_content({
        typeArguments: [],
        functionArguments: [],
      })
      .then((result) => {
        console.log("message content", result);
        setBooleanContent(result[0]);
        setStringContent(result[1]);
        setNumberContent(parseInt(result[2]));
        setAddressContent(result[3]);
        setObjectContent(result[4]);
        setVectorContent(result[5]);
        setOptionalBooleanContent(result[6]);
        setOptionalStringContent(result[7]);
        setOptionalNumberContent(result[8]);
        setOptionalAddressContent(result[9]);
        setOptionalObjectContent(result[10]);
        setOptionalVectorContent(result[11]);
      })
      .catch((error) => {
        console.error(error);
      });
  }, []);

  return (
    <div className="flex flex-col gap-6">
      <p>Message content</p>
      <LabelValueGrid
        items={[
          {
            label: "Boolean Content",
            value: <p>{String(booleanContent)}</p>,
          },
          {
            label: "String Content",
            value: <p>{stringContent}</p>,
          },
          {
            label: "Number Content",
            value: <p>{numberContent}</p>,
          },
          {
            label: "Address Content",
            value: <p>{addressContent}</p>,
          },
          {
            label: "Object Content",
            value: <p>{JSON.stringify(objectContent)}</p>,
          },
          {
            label: "Vector Content",
            value: <p>{JSON.stringify(vectorContent)}</p>,
          },
          {
            label: "Optional Boolean Content",
            value: <p>{String(optionalBooleanContent?.vec.length === 0 ? "none" : optionalBooleanContent?.vec[0])}</p>,
          },
          {
            label: "Optional String Content",
            value: <p>{optionalStringContent?.vec.length === 0 ? "none" : optionalStringContent?.vec[0]}</p>,
          },
          {
            label: "Optional Number Content",
            value: <p>{optionalNumberContent?.vec.length === 0 ? "none" : optionalNumberContent?.vec[0]}</p>,
          },
          {
            label: "Optional Address Content",
            value: <p>{optionalAddressContent?.vec.length === 0 ? "none" : optionalAddressContent?.vec[0]}</p>,
          },
          {
            label: "Optional Object Content",
            value: (
              <p>{JSON.stringify(optionalObjectContent?.vec.length === 0 ? "none" : optionalObjectContent?.vec[0])}</p>
            ),
          },
          {
            label: "Optional Vector Content",
            value: (
              <p>{JSON.stringify(optionalVectorContent?.vec.length === 0 ? "none" : optionalVectorContent?.vec[0])}</p>
            ),
          },
        ]}
      />
    </div>
  );
}
