export const ABI = {
  address: "0x5425649a7f3e5ad9b029c9727e5290fffeca6e28d1f8b0fabaf992465cae2ac2",
  name: "counter_app",
  friends: [],
  exposed_functions: [
    {
      name: "click",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [],
      params: ["&signer"],
      return: [],
    },
    {
      name: "count",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["address"],
      return: ["u64"],
    },
  ],
  structs: [
    {
      name: "Counter",
      is_native: false,
      abilities: ["key"],
      generic_type_params: [],
      fields: [{ name: "count", type: "u64" }],
    },
  ],
} as const;
