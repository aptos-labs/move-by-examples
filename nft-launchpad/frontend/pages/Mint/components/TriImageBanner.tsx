import { useMemo } from "react";
// Internal components
import { Image } from "@/components/ui/image";

export function TriImageBanner({ images, className }: { images: string[]; className?: string }) {
  const threeImages = useMemo(() => {
    return images.slice(0, 3);
  }, [images]);

  const hasMultipleImages = threeImages.length > 1;

  return (
    <div className={className + " whitespace-nowrap"}>
      {threeImages.map((image, i) => (
        <Image
          style={{
            width: hasMultipleImages ? `${50 - i * 10}%` : "100%",
            aspectRatio: "1/1",
            display: "inline-block",
            position: "relative",
            left: `-${i * 15}%`,
            zIndex: -i,
          }}
          rounded
          src={image}
          key={`${i}-${image}`}
        />
      ))}
    </div>
  );
}
