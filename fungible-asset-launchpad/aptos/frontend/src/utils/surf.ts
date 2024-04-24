import { DefaultABITable, ExtractStructType } from "@thalalabs/surf";
import { ABI } from "./abi";

const contract = `${ABI.address}::${ABI.name}`;
const contract2 =
  "0xb439206f340d4136e6a862a49477475c3de540363205bb523826e4c84a9f5b49::launchpad";
type ABITAble = DefaultABITable & {
  [contract: string]: typeof ABI;
};

export type Registry = ExtractStructType<ABITAble, typeof ABI, "Registry">;
export type FAController = ExtractStructType<
  ABITAble,
  typeof ABI,
  "FAController"
>;
export type CreateFAEvent = ExtractStructType<
  ABITAble,
  typeof ABI,
  "CreateFAEvent"
>;
export type MintFAEvent = ExtractStructType<
  ABITAble,
  typeof ABI,
  "MintFAEvent"
>;
