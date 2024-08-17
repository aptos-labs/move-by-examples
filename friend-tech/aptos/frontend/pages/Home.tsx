import { Link } from "react-router-dom";

import { Header } from "@/components/Header";
import { Table, TableBody, TableCaption, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { useGetIssuers } from "@/hooks/useIssuer";

export function Home() {
  const issuers = useGetIssuers();

  return (
    <>
      <Header title="Aptos Friend" />
      <Table className="max-w-screen-xl mx-auto">
        {!issuers.length && <TableCaption>All users who have issued shares.</TableCaption>}
        <TableHeader>
          <TableRow>
            <TableHead>Username</TableHead>
            <TableHead>Issuer address</TableHead>
            <TableHead>Total issued shares</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {issuers.length > 0 &&
            issuers.map((issuer) => {
              return (
                <TableRow key={issuer.issuerObjectAddress}>
                  <TableCell>{issuer.username}</TableCell>
                  <TableCell>
                    <Link to={`/issuer/${issuer.issuerAddress}`} style={{ textDecoration: "underline" }}>
                      {issuer.issuerAddress}
                    </Link>
                  </TableCell>
                  <TableCell>{issuer.totalIssuedShares}</TableCell>
                </TableRow>
              );
            })}
        </TableBody>
      </Table>
    </>
  );
}
