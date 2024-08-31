import { SelectSingleEventHandler } from "react-day-picker";
import { format } from "date-fns";
import { Label } from "./label";
import { Popover, PopoverContent, PopoverTrigger } from "./popover";
import { cn } from "@/lib/utils";
import { CalendarIcon } from "lucide-react";
import { FC } from "react";
import { Calendar } from "./calendar";
import { Input } from "./input";
import { Button } from "./button";

export const DateTimeInput: FC<{
  className?: string;
  label: string;
  required?: boolean;
  tooltip: string;
  disabled?: boolean;
  date?: Date;
  onDateChange: SelectSingleEventHandler;
  time?: string;
  onTimeChange: (event: React.ChangeEvent<HTMLInputElement>) => void;
  id: string;
}> = ({
  className,
  id,
  tooltip,
  label,
  disabled,
  date,
  onDateChange,
  time,
  onTimeChange,
}) => {
  return (
    <div className={cn("flex flex-col gap-4", className)}>
      <Label htmlFor={id} tooltip={tooltip}>
        {label}
      </Label>
      <Popover>
        <PopoverTrigger asChild>
          <Button
            disabled={disabled}
            id={id}
            variant="outline"
            className={cn(
              "justify-start text-left font-normal",
              !date && "text-muted-foreground"
            )}>
            <CalendarIcon className="mr-2 h-4 w-4" />
            {date ? (
              format(date, "MM/dd/yyyy hh:mm a")
            ) : (
              <span>Pick a date</span>
            )}
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-auto">
          <Calendar
            mode="single"
            selected={date}
            onSelect={onDateChange}
            initialFocus
            footer={
              <Input
                type="time"
                className="w-max py-6"
                value={time}
                onChange={onTimeChange}
              />
            }
          />
        </PopoverContent>
      </Popover>
    </div>
  );
};
