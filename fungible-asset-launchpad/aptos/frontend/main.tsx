import "./index.css";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import React from "react";
import ReactDOM from "react-dom/client";

import App from "@/App.tsx";
// Internal components
import { Toaster } from "@/components/ui/toaster.tsx";
import { TooltipProvider } from "@/components/ui/tooltip.tsx";
import { WalletProvider } from "@/components/WalletProvider.tsx";

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <WalletProvider>
      <QueryClientProvider client={queryClient}>
        <TooltipProvider delayDuration={100}>
          <App />
          <Toaster />
        </TooltipProvider>
      </QueryClientProvider>
    </WalletProvider>
  </React.StrictMode>,
);
