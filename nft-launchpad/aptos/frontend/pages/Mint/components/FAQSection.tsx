// Internal config
import { config } from "@/config";
// Internal components
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";

interface FAQSectionProps {}

export const FAQSection: React.FC<FAQSectionProps> = () => {
  if (!config.faqs || !config.faqs.questions.length) return null;

  return (
    <section className="faq-container px-4 max-w-screen-xl mx-auto w-full">
      <h2 className="text-center heading-md">{config.faqs.title}</h2>

      <Accordion type="multiple">
        {config.faqs.questions.map(({ title, description }, i) => (
          <AccordionItem value={`${i}-${title}`} key={`${i}-${title}`}>
            <AccordionTrigger>
              <p className="body-md-semibold">{title}</p>
            </AccordionTrigger>
            <AccordionContent>
              <p className="body-sm py-4">{description}</p>
            </AccordionContent>
          </AccordionItem>
        ))}
      </Accordion>
    </section>
  );
};
