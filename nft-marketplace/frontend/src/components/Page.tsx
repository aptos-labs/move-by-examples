import { Box } from "@chakra-ui/react";
import { ReactNode } from "react";

export default function Page({ children }: { children: ReactNode }) {
  return (
    <Box marginX={16} marginTop={8} marginBottom={80}>
      {children}
    </Box>
  );
}
