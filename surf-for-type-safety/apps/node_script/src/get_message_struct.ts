import { client } from "./utils";

const run = async () => {
  const messageObjAddr =
    "0xfeada0eb03117317786626d337cfbf9745143f41d1e13f72ed676a0a8551c82d";
  client.view
    .get_message_struct({
      typeArguments: [],
      functionArguments: [messageObjAddr],
    })
    .then(console.log);
};

run();
