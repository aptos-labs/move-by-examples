require("dotenv").config();
const fs = require("node:fs");
const yaml = require("js-yaml");
const cli = require("@aptos-labs/ts-sdk/dist/common/cli/index.js");

const config = yaml.load(fs.readFileSync("./.aptos/config.yaml", "utf8"));
const accountAddress = config["profiles"][`${process.env.PROJECT_NAME}-${process.env.VITE_APP_NETWORK}`]["account"];

async function compile() {
  const move = new cli.Move();

  await move.compile({
    packageDirectoryPath: "move",
    namedAddresses: {
      // Publish module to account address
      launchpad_addr: accountAddress,
      // Our contract depends on the token-minter contract to provide some common NFT functionalities like managing refs and mint stages
      // You can read the source code of it here: https://github.com/aptos-labs/token-minter/
      // Please find it on the network you are using, This is testnet deployment
      minter: "0x3c41ff6b5845e0094e19888cba63773591be9de59cafa9e582386f6af15dd490",
    },
  });
}
compile();
