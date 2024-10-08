export const ABI = {
  address: "0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0",
  name: "aptos_friend",
  friends: [],
  exposed_functions: [
    {
      name: "buy_share",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [],
      params: [
        "&signer",
        "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>",
        "u64",
      ],
      return: [],
    },
    {
      name: "calculate_buy_share_cost",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [
        "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>",
        "u64",
      ],
      return: ["u64", "u64", "u64", "u64"],
    },
    {
      name: "calculate_sell_share_cost",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [
        "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>",
        "u64",
      ],
      return: ["u64", "u64", "u64", "u64"],
    },
    {
      name: "get_holding",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [
        "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Holding>",
      ],
      return: ["address", "address", "u64"],
    },
    {
      name: "get_holding_obj",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["address", "address"],
      return: [
        "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Holding>",
      ],
    },
    {
      name: "get_holding_obj_addr",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["address", "address"],
      return: ["address"],
    },
    {
      name: "get_issuer",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [
        "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>",
      ],
      return: ["address", "0x1::string::String", "u64"],
    },
    {
      name: "get_issuer_holder_holdings",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [
        "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>",
      ],
      return: [
        "vector<0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Holding>>",
      ],
    },
    {
      name: "get_issuer_obj",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["address"],
      return: [
        "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>",
      ],
    },
    {
      name: "get_issuer_obj_addr",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["address"],
      return: ["address"],
    },
    {
      name: "get_issuer_registry",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: [
        "vector<0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>>",
      ],
    },
    {
      name: "get_user_holdings",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [
        "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::User>",
      ],
      return: [
        "vector<0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Holding>>",
      ],
    },
    {
      name: "get_user_obj",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["address"],
      return: [
        "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::User>",
      ],
    },
    {
      name: "get_user_obj_addr",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["address"],
      return: ["address"],
    },
    {
      name: "get_vault_addr",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: [],
      return: ["address"],
    },
    {
      name: "has_issued_share",
      visibility: "public",
      is_entry: false,
      is_view: true,
      generic_type_params: [],
      params: ["address"],
      return: ["bool"],
    },
    {
      name: "issue_share",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [],
      params: ["&signer", "0x1::string::String"],
      return: [],
    },
    {
      name: "sell_share",
      visibility: "public",
      is_entry: true,
      is_view: false,
      generic_type_params: [],
      params: [
        "&signer",
        "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>",
        "u64",
      ],
      return: [],
    },
  ],
  structs: [
    {
      name: "BuyShareEvent",
      is_native: false,
      abilities: ["drop", "store"],
      generic_type_params: [],
      fields: [
        { name: "issuer_addr", type: "address" },
        {
          name: "issuer_obj",
          type: "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>",
        },
        { name: "buyer_addr", type: "address" },
        {
          name: "buyer_user_obj",
          type: "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::User>",
        },
        { name: "amount", type: "u64" },
        { name: "share_cost", type: "u64" },
        { name: "issuer_fee", type: "u64" },
        { name: "protocol_fee", type: "u64" },
        { name: "total_cost", type: "u64" },
      ],
    },
    {
      name: "Holding",
      is_native: false,
      abilities: ["key"],
      generic_type_params: [],
      fields: [
        { name: "issuer", type: "address" },
        { name: "holder", type: "address" },
        { name: "shares", type: "u64" },
      ],
    },
    {
      name: "IssueShareEvent",
      is_native: false,
      abilities: ["drop", "store"],
      generic_type_params: [],
      fields: [
        { name: "issuer_addr", type: "address" },
        {
          name: "issuer_obj",
          type: "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>",
        },
        { name: "username", type: "0x1::string::String" },
      ],
    },
    {
      name: "Issuer",
      is_native: false,
      abilities: ["key"],
      generic_type_params: [],
      fields: [
        { name: "addr", type: "address" },
        { name: "username", type: "0x1::string::String" },
        { name: "total_issued_shares", type: "u64" },
        {
          name: "holder_holdings",
          type: "vector<0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Holding>>",
        },
      ],
    },
    {
      name: "IssuerRegistry",
      is_native: false,
      abilities: ["key"],
      generic_type_params: [],
      fields: [
        {
          name: "issuers",
          type: "vector<0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>>",
        },
      ],
    },
    {
      name: "SellShareEvent",
      is_native: false,
      abilities: ["drop", "store"],
      generic_type_params: [],
      fields: [
        { name: "issuer_addr", type: "address" },
        {
          name: "issuer_obj",
          type: "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Issuer>",
        },
        { name: "seller_addr", type: "address" },
        {
          name: "seller_user_obj",
          type: "0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::User>",
        },
        { name: "amount", type: "u64" },
        { name: "share_cost", type: "u64" },
        { name: "issuer_fee", type: "u64" },
        { name: "protocol_fee", type: "u64" },
        { name: "total_cost", type: "u64" },
      ],
    },
    {
      name: "User",
      is_native: false,
      abilities: ["key"],
      generic_type_params: [],
      fields: [
        {
          name: "holdings",
          type: "vector<0x1::object::Object<0x5a8755c03d8bfeda18dffce91495d6edbf01bae888e8f329f461ace2e901a7c0::aptos_friend::Holding>>",
        },
      ],
    },
    {
      name: "Vault",
      is_native: false,
      abilities: ["key"],
      generic_type_params: [],
      fields: [{ name: "extend_ref", type: "0x1::object::ExtendRef" }],
    },
  ],
} as const;
