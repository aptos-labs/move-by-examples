"use client";

import { ColumnDef } from "@tanstack/react-table";

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Button } from "../ui/button";
import { ObjectOnExplorer } from "../ExplorerLink";
import { MoreHorizontal } from "lucide-react";

export type Message = {
  messageObjectAddress: string;
};

export const columns: ColumnDef<Message>[] = [
  {
    accessorKey: "messageObjectAddress",
    header: "Message Object Address",
    cell: ({ row }) => (
      <div className="capitalize">{row.getValue("messageObjectAddress")}</div>
    ),
    accessorFn: (row) => row.messageObjectAddress,
  },
  {
    id: "actions",
    enableHiding: false,
    cell: ({ row }) => {
      const message = row.original;
      return (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" className="h-8 w-8 p-0">
              <span className="sr-only">Open menu</span>
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuLabel>Actions</DropdownMenuLabel>
            <DropdownMenuItem
              onClick={() =>
                navigator.clipboard.writeText(message.messageObjectAddress)
              }
            >
              Copy message object address
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem>
              <ObjectOnExplorer address={message.messageObjectAddress} />
            </DropdownMenuItem>
            <DropdownMenuItem>
              <a
                href={`/message/${message.messageObjectAddress}`}
                rel="noreferrer"
                className="text-blue-600 dark:text-blue-300"
              >
                View message content
              </a>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      );
    },
  },
];
