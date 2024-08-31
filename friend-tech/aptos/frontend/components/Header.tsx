import { FC } from "react";
import { Link } from "react-router-dom";

import { WalletSelector } from "@/components/WalletSelector";
import { buttonVariants } from "@/components/ui/button";

type LaunchpadHeaderProps = {
  title: string;
};

export const Header: FC<LaunchpadHeaderProps> = ({ title }) => {
  return (
    <div className="flex items-center justify-between py-2 px-4 mx-auto w-full max-w-screen-xl flex-wrap">
      <h2 className="display">
        <a href="/">{title}</a>
      </h2>
      <div className="flex gap-2 items-center">
        <Link className={buttonVariants({ variant: "link" })} to={"/my-profile"}>
          My Profile
        </Link>
        <WalletSelector />
      </div>
    </div>
  );
};
