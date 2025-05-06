import type { Metadata } from "next";
import { Providers } from "./provider";
import { ReactNode } from "react";
import { NavBar } from "@/components/Navbar";
import Page from "@/components/Page";

export const metadata: Metadata = {
  title: "NFT Marketplace",
  description: "NFT Marketplace for Aptogotchi Collection",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Providers>
          <NavBar />
          <Page>{children}</Page>
        </Providers>
      </body>
    </html>
  );
}
