import { Card } from "@/components/ui/card";
import { clampNumber } from "@/utils/clampNumber";
import { useGetAssetData } from "../../../hooks/useGetAssetData";

interface StatsSectionProps {
  faAddress?: string;
}

export const StatsSection: React.FC<StatsSectionProps> = ({ faAddress }: StatsSectionProps) => {
  const { data } = useGetAssetData(faAddress);
  if (!data) return null;
  const { maxSupply, currentSupply, uniqueHolders } = data;

  return (
    <section className="stats-container px-4 max-w-screen-xl mx-auto w-full">
      <ul className="flex flex-col md:flex-row gap-6">
        {[
          { title: "Max Supply", value: maxSupply },
          { title: "Current Supply", value: currentSupply },
          { title: "Unique Holders", value: uniqueHolders },
        ].map(({ title, value }) => (
          <li className="basis-1/3" key={title + " " + value}>
            <Card className="py-2 px-4" shadow="md">
              <p className="label-sm">{title}</p>
              <p className="heading-sm">{clampNumber(value)}</p>
            </Card>
          </li>
        ))}
      </ul>
    </section>
  );
};
