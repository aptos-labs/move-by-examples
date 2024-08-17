import { FC } from "react";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "./alert-dialog";
import { Button } from "./button";

export const ConfirmButton: FC<{
  title: string;
  disabled?: boolean;
  onSubmit: () => void;
  confirmMessage: React.ReactNode;
  className?: string;
}> = ({ className, onSubmit, disabled, title, confirmMessage }) => {
  return (
    <AlertDialog>
      <AlertDialogTrigger asChild>
        <Button className={className} variant="green" disabled={disabled}>
          {title}
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Confirm</AlertDialogTitle>
          <div className="flex flex-col gap-2 text-sm text-muted-foreground">
            {confirmMessage}
          </div>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>Cancel</AlertDialogCancel>
          <AlertDialogAction onClick={onSubmit}>Continue</AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
};
