import { Link } from "react-router-dom";

import { Table, TableBody, TableCaption, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { useGetHoldings } from "@/hooks/useHolding";

type UserHoldingsProps = {
  userAddress: `0x${string}`;
};

export function UserHoldings({ userAddress }: UserHoldingsProps) {
  const holdings = useGetHoldings(userAddress);

  return (
    <Card className="w-full">
      <CardHeader>
        <CardTitle>Holdings</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <Table className="max-w-screen-xl mx-auto">
          {holdings && !holdings.length && <TableCaption>All holdings.</TableCaption>}
          <TableHeader>
            <TableRow>
              <TableHead>Issuer address</TableHead>
              <TableHead>Shares hold</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {holdings &&
              holdings.length > 0 &&
              holdings.map((holding) => {
                return (
                  <TableRow key={holding.issuer}>
                    <TableCell>
                      <Link to={`/issuer/${holding.issuer}`} style={{ textDecoration: "underline" }}>
                        {holding.issuer}
                      </Link>
                    </TableCell>
                    <TableCell>{holding.shares}</TableCell>
                  </TableRow>
                );
              })}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}
