import * as React from "react";
import { Info as InfoIcon } from "lucide-react";

import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";

export interface InfoProps {
  description: string;
}

export const Info: React.FC<InfoProps> = ({ description }) => {
  return (
    <Tooltip>
      <TooltipTrigger>
        <InfoIcon className="w-4 h-4 text-gray-400" />
      </TooltipTrigger>

      <TooltipContent>
        <p className="max-w-md">{description}</p>
      </TooltipContent>
    </Tooltip>
  );
};
