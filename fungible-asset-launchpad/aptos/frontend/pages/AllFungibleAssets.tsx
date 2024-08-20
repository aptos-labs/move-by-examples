import { Link } from "react-router-dom";
// Internal components
import { Header } from "@/components/Header";
import { Table, TableBody, TableCaption, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
// Internal hooks
import { useGetAssetMetadata } from "@/hooks/useGetAssetMetadata";
import { convertAmountFromOnChainToHumanReadable } from "@/utils/helpers";

export function AllFungibleAssets() {
  const fas = useGetAssetMetadata();

  return (
    <>
      <Header />
      <Table className="max-w-screen-xl mx-auto">
        {!fas.length && <TableCaption>A list of the fungible assets created under the current launchpad.</TableCaption>}
        <TableHeader>
          <TableRow>
            <TableHead className="w-[100px]">Symbol</TableHead>
            <TableHead>Asset Name (click to mint)</TableHead>
            <TableHead>FA address</TableHead>
            <TableHead>Max Supply</TableHead>
            <TableHead>Minted</TableHead>
            <TableHead>Decimal</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {fas.length > 0 &&
            fas.map((fa) => {
              return (
                <TableRow key={fa.asset_type}>
                  <TableCell className="font-medium">
                    <div className="flex items-center">
                      <img src={fa.icon_uri ?? ""} style={{ width: "40px" }} className="mr-2"></img>
                      <span>{fa.symbol}</span>
                    </div>
                  </TableCell>
                  <TableCell>
                    <Link to={`/mint/${fa.asset_type}`} target="_blank" style={{ textDecoration: "underline" }}>
                      {fa.name}
                    </Link>
                  </TableCell>
                  <TableCell>
                    <Link
                      to={`https://explorer.aptoslabs.com/object/${
                        fa.asset_type
                      }?network=${import.meta.env.VITE_APP_NETWORK}`}
                      target="_blank"
                      style={{ textDecoration: "underline" }}
                    >
                      {fa.asset_type}
                    </Link>
                  </TableCell>
                  <TableCell>{convertAmountFromOnChainToHumanReadable(fa.maximum_v2, fa.decimals)}</TableCell>
                  <TableCell>{convertAmountFromOnChainToHumanReadable(fa.supply_v2, fa.decimals)}</TableCell>
                  <TableCell>{fa.decimals}</TableCell>
                </TableRow>
              );
            })}
        </TableBody>
      </Table>
    </>
  );
}
