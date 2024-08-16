import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";

const imageVariants = cva("", {
  variants: {
    rounded: {
      true: "rounded-lg",
      full: "rounded-full",
    },
  },
  defaultVariants: {
    rounded: false,
  },
});

export interface ImageProps
  extends React.ImgHTMLAttributes<HTMLImageElement>,
    VariantProps<typeof imageVariants> {}

const Image = React.forwardRef<HTMLImageElement, ImageProps>(
  ({ className, rounded, ...props }, ref) => {
    return (
      <img
        className={cn(imageVariants({ rounded, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);
Image.displayName = "Image";

export { Image, imageVariants };
