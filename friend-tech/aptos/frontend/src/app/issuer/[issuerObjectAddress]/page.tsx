import { Issuer } from "@/components/Issuer";

type Props = {
  params: { issuerObjectAddress: `0x${string}` };
};

export default async function Page({ params: { issuerObjectAddress } }: Props) {
  return <Issuer issuerObjectAddress={issuerObjectAddress} />;
}
