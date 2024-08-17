import { Link } from "react-router-dom";

import { useGetHolders } from "@/hooks/useHolder";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

type IssuerShareHoldersProps = {
  issuerAddress: `0x${string}`;
};

export function IssuerShareHolders({ issuerAddress }: IssuerShareHoldersProps) {
  const holders = useGetHolders(issuerAddress);

  return (
    <Card className="w-full">
      <CardHeader>
        <CardTitle>Holders</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <Table className="max-w-screen-xl mx-auto">
          <TableHeader>
            <TableRow>
              <TableHead>Holder address</TableHead>
              <TableHead>Shares hold</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {holders &&
              holders.map((holder) => {
                return (
                  <TableRow key={holder.holder}>
                    <TableCell>
                      <Link
                        to={`https://explorer.aptoslabs.com/account/${
                          holder.holder
                        }?network=${import.meta.env.VITE_APP_NETWORK}`}
                        target="_blank"
                        style={{ textDecoration: "underline" }}
                      >
                        {holder.holder}
                      </Link>
                    </TableCell>
                    <TableCell>{holder.shares}</TableCell>
                  </TableRow>
                );
              })}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}
