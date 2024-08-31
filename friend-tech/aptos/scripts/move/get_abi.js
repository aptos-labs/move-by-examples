require("dotenv").config();
const axios = require("axios");
const fs = require("node:fs");

const moduleName = "aptos_friend";

const url = `https://fullnode.${process.env.VITE_APP_NETWORK}.aptoslabs.com/v1/accounts/${process.env.VITE_MODULE_ADDRESS}/module/${moduleName}`;

async function getAbi() {
  axios
    .get(url)
    .then((response) => {
      const abi = response.data.abi;
      const abiString = `export const ABI = ${JSON.stringify(abi)} as const;`;
      fs.writeFileSync("frontend/utils/abi.ts", abiString);
      console.log("ABI saved to frontend/utils/abi.ts");
    })
    .catch((error) => {
      console.error("Error fetching ABI:", error);
    });
}

getAbi();
