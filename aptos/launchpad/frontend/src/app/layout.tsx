import type { Metadata } from "next";
import { Providers } from "@/app/providers";
import { ReactNode } from "react";
import { NavBar } from "@/components/Navbar";
import { Box } from "@chakra-ui/react";

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
          <Box marginX={16} marginTop={8} marginBottom={80}>
            {children}
          </Box>
        </Providers>
      </body>
    </html>
  );
}
