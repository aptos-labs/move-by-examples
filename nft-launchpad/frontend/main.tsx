import "./index.css";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import React from "react";
import ReactDOM from "react-dom/client";

import App from "@/App";
import { WalletProvider } from "@/components/WalletProvider";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { WrongNetworkAlert } from "@/components/WrongNetworkAlert";

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <WalletProvider>
      <QueryClientProvider client={queryClient}>
        <TooltipProvider delayDuration={100}>
          <WrongNetworkAlert />
          <App />
          <Toaster />
        </TooltipProvider>
      </QueryClientProvider>
    </WalletProvider>
  </React.StrictMode>,
);
