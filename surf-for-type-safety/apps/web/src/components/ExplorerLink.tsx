import { NETWORK_NAME } from "@/lib/aptos";

export interface TransactionOnExplorerProps {
  hash: string;
}

export function TransactionOnExplorer({ hash }: TransactionOnExplorerProps) {
  const explorerLink = `https://explorer.aptoslabs.com/txn/${hash}${`?network=${NETWORK_NAME}`}`;
  return (
    <>
      View on Explorer:{" "}
      <a
        href={explorerLink}
        target="_blank"
        rel="noreferrer"
        className="text-blue-600 dark:text-blue-300"
      >
        {explorerLink}
      </a>
    </>
  );
}

export interface ObjectOnExplorerProps {
  address: string;
}

export function ObjectOnExplorer({ address }: ObjectOnExplorerProps) {
  const explorerLink = `https://explorer.aptoslabs.com/object/${address}${`?network=${NETWORK_NAME}`}`;
  return (
    <a
      href={explorerLink}
      target="_blank"
      rel="noreferrer"
      className="text-blue-600 dark:text-blue-300"
    >
      View on Explorer
    </a>
  );
}
