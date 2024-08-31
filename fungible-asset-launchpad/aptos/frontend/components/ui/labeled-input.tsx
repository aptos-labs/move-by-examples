import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { FC } from "react";

export const LabeledInput: FC<{
  label: string;
  required?: boolean;
  tooltip: string;
  disabled?: boolean;
  value?: number | string;
  type?: "number" | "text";
  id: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}> = ({
  label,
  required,
  tooltip,
  disabled,
  value,
  onChange,
  id,
  type = "number",
}) => {
  return (
    <div className="flex flex-col item-center space-y-4 mt-4">
      <Label htmlFor={id} tooltip={tooltip}>
        {label} {required ? "" : "(optional)"}
      </Label>
      <Input
        disabled={disabled}
        type={type}
        id={id}
        value={value}
        onChange={onChange}
      />
    </div>
  );
};
