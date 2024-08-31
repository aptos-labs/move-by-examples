import { FC } from "react";
// Internal components
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Image } from "@/components/ui/image";
import { ConfigTeamMember, config } from "@/config";
// Internal assets
import Twitter from "@/assets/icons/twitter.svg";
import Discord from "@/assets/icons/discord.svg";

interface OurTeamSectionProps {}

export const OurTeamSection: React.FC<OurTeamSectionProps> = () => {
  if (!config.ourTeam) return null;

  return (
    <section className="team-container px-4 max-w-screen-xl mx-auto w-full">
      <h2 className="text-center heading-md">{config.ourTeam.title}</h2>
      <ul className="flex flex-col sm:flex-row justify-center items-center gap-4 flex-wrap mt-4">
        {config.ourTeam.members.map((member, i) => (
          <li key={`${member.name}-${i}`} className="basis-1/3 max-w-64">
            <TeamCard member={member} />
          </li>
        ))}
      </ul>
    </section>
  );
};

const TeamCard: FC<{ member: ConfigTeamMember }> = ({ member }) => {
  return (
    <Card>
      <CardHeader>
        <Image src={member.img} rounded />
      </CardHeader>
      <CardContent>
        <CardTitle className="flex justify-center gap-2 items-center">
          {member.name}
          {member.socials?.twitter && (
            <a target="_blank" href={member.socials.twitter}>
              <Image width={16} height={16} src={Twitter} className="dark:invert" />
            </a>
          )}
          {member.socials?.discord && (
            <a target="_blank" href={member.socials.discord}>
              <Image width={16} height={16} src={Discord} className="dark:invert" />
            </a>
          )}
        </CardTitle>
        <CardDescription className="text-center text-secondary-text">{member.role}</CardDescription>
      </CardContent>
    </Card>
  );
};
