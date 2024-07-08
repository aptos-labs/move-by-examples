import { useEffect, useState } from "react";

import { surfClient } from "@/utils/aptosClient";
import { LabelValueGrid } from "@/components/LabelValueGrid";

export function Message() {
  const [booleanContent, setBooleanContent] = useState<boolean>();
  const [stringContent, setStringContent] = useState<string>();
  const [numberContent, setNumberContent] = useState<number>();
  const [addressContent, setAddressContent] = useState<string>();
  const [objectContent, setObjectContent] = useState<any>();
  const [vectorContent, setVectorContent] = useState<any>();
  const [optionalBooleanContent, setOptionalBooleanContent] = useState<any>();
  const [optionalStringContent, setOptionalStringContent] = useState<any>();
  const [optionalNumberContent, setOptionalNumberContent] = useState<any>();
  const [optionalAddressContent, setOptionalAddressContent] = useState<any>();
  const [optionalObjectContent, setOptionalObjectContent] = useState<any>();
  const [optionalVectorContent, setOptionalVectorContent] = useState<any>();

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
            // @ts-ignore
            value: <p>{String(optionalBooleanContent?.vec)}</p>,
          },
          {
            label: "Optional String Content",
            // @ts-ignore
            value: <p>{optionalStringContent?.vec}</p>,
          },
          {
            label: "Optional Number Content",
            // @ts-ignore
            value: <p>{optionalNumberContent?.vec}</p>,
          },
          {
            label: "Optional Address Content",
            // @ts-ignore
            value: <p>{optionalAddressContent?.vec}</p>,
          },
          {
            label: "Optional Object Content",
            // @ts-ignore
            value: <p>{JSON.stringify(optionalObjectContent?.vec)}</p>,
          },
          {
            label: "Optional Vector Content",
            // @ts-ignore
            value: <p>{JSON.stringify(optionalVectorContent?.vec)}</p>,
          },
        ]}
      />
    </div>
  );
}
