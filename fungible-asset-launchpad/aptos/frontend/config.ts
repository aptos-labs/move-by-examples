import Placeholder1 from "@/assets/placeholders/asset.png";

export const config: Config = {
  // Removing one or all of these socials will remove them from the page
  socials: {
    twitter: "https://twitter.com",
    discord: "https://discord.com",
    homepage: "#",
  },

  defaultAsset: {
    name: "Tempor Ea Sunt",
    image: Placeholder1,
  },

  ourStory: {
    title: "Reprehenderit Do Anim In",
    description: `Veniam ut aliqua quis non dolore nostrud labore elit proident dolore. Elit non consectetur dolore est nostrud cupidatat dolore incididunt elit veniam pariatur irure pariatur. Consectetur incididunt tempor aute dolore deserunt et enim occaecat non excepteur labore magna. Laboris commodo nostrud dolore Lorem ex occaecat sunt id id sint proident amet Lorem Lorem.`,
    discordLink: "https://discord.com",
  },
};

export interface Config {
  socials?: {
    twitter?: string;
    discord?: string;
    homepage?: string;
  };

  defaultAsset?: {
    name: string;
    image: string;
  };

  ourStory?: {
    title: string;
    subTitle?: string;
    description: string;
    discordLink: string;
  };
}
