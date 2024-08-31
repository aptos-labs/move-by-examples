require("dotenv").config();
const cli = require("@aptos-labs/ts-sdk/dist/common/cli/index.js");

async function publish() {
  // Check VITE_MODULE_ADDRESS is set
  if (!process.env.VITE_MODULE_ADDRESS) {
    throw new Error(
      "VITE_MODULE_ADDRESS variable is not set, make sure you have published the module before upgrading it",
    );
  }

  const move = new cli.Move();

  move.upgradeObjectPackage({
    packageDirectoryPath: "move",
    objectAddress: process.env.VITE_MODULE_ADDRESS,
    namedAddresses: {
      // Upgrade module from an object
      launchpad_addr: process.env.VITE_MODULE_ADDRESS,
      // Our contract depends on the token-minter contract to provide some common functionalities like managing refs and mint stages
      // You can read the source code of it here: https://github.com/aptos-labs/token-minter/
      // Please find it on the network you are using, This is testnet deployment
      minter: "0x3c41ff6b5845e0094e19888cba63773591be9de59cafa9e582386f6af15dd490",
    },
    profile: `${process.env.PROJECT_NAME}-${process.env.VITE_APP_NETWORK}`,
  });
}
publish();
