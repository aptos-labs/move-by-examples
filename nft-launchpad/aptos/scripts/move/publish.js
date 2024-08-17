require("dotenv").config();
const fs = require("node:fs");
const yaml = require("js-yaml");
const cli = require("@aptos-labs/ts-sdk/dist/common/cli/index.js");

const config = yaml.load(fs.readFileSync("./.aptos/config.yaml", "utf8"));
const accountAddress = config["profiles"][`${process.env.PROJECT_NAME}-${process.env.VITE_APP_NETWORK}`]["account"];

async function publish() {
  const move = new cli.Move();

  move
    .createObjectAndPublishPackage({
      packageDirectoryPath: "move",
      addressName: "launchpad_addr",
      namedAddresses: {
        // Publish module to new object, but since we create the object on the fly, we fill in the publisher's account address here
        launchpad_addr: accountAddress,
        // Our contract depends on the token-minter contract to provide some common functionalities like managing refs and mint stages
        // You can read the source code of it here: https://github.com/aptos-labs/token-minter/
        // Please find it on the network you are using, This is testnet deployment
        minter: "0x3c41ff6b5845e0094e19888cba63773591be9de59cafa9e582386f6af15dd490",
      },
      profile: `${process.env.PROJECT_NAME}-${process.env.VITE_APP_NETWORK}`,
    })
    .then((response) => {
      const filePath = ".env";
      let envContent = "";

      // Check .env file exists and read it
      if (fs.existsSync(filePath)) {
        envContent = fs.readFileSync(filePath, "utf8");
      }

      // Regular expression to match the VITE_MODULE_ADDRESS variable
      const regex = /^VITE_MODULE_ADDRESS=.*$/m;
      const newEntry = `VITE_MODULE_ADDRESS=${response.objectAddress}`;

      // Check if VITE_MODULE_ADDRESS is already defined
      if (envContent.match(regex)) {
        // If the variable exists, replace it with the new value
        envContent = envContent.replace(regex, newEntry);
      } else {
        // If the variable does not exist, append it
        envContent += `\n${newEntry}`;
      }

      // Write the updated content back to the .env file
      fs.writeFileSync(filePath, envContent, "utf8");
    });
}
publish();
