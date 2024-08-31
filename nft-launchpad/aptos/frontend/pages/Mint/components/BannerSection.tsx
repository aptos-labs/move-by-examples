import { useMemo } from "react";
// Internal components
import { Image } from "@/components/ui/image";
// Internal utils
import { cn } from "@/lib/utils";
// Internal config
import { config } from "@/config";

interface BannerSectionProps {
  className?: string;
}

export const BannerSection: React.FC<BannerSectionProps> = ({ className }) => {
  const images = config.nftBanner;
  const repeatedImages = useMemo(() => {
    let res: string[] = [];
    if (!images?.length) return res;
    while (res.length < 60) {
      res = res.concat(images ?? []);
    }
    return res;
  }, [images]);

  if (!repeatedImages.length) return null;

  return (
    <div className={cn("w-full grid grid-cols-[repeat(30,minmax(136px,1fr))] grid-rows-2 gap-4 -mx-16", className)}>
      {repeatedImages.slice(0, 60).map((image, i) => {
        return <Image rounded className="aspect-square" src={image} key={`${i}-${image}`} />;
      })}
    </div>
  );
};
