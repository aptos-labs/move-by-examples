export type FriendTech = {
  "version": "0.1.0",
  "name": "friend_tech",
  "instructions": [
    {
      "name": "initialize",
      "accounts": [
        {
          "name": "config",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "signer",
          "isMut": true,
          "isSigner": true,
          "docs": [
            "Solana Stuff"
          ]
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "bump",
          "type": "u8"
        }
      ]
    },
    {
      "name": "initIssuerShare",
      "accounts": [
        {
          "name": "issuerShare",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "config",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "issuerPubkey",
          "isMut": false,
          "isSigner": false,
          "docs": [
            "CHECK issuer pubkey"
          ]
        },
        {
          "name": "socialMediaHandle",
          "isMut": false,
          "isSigner": false,
          "docs": [
            "CHECK social media pda"
          ]
        },
        {
          "name": "signer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "bump",
          "type": "u8"
        },
        {
          "name": "configBump",
          "type": "u8"
        }
      ]
    },
    {
      "name": "initIssuerHolding",
      "accounts": [
        {
          "name": "issuerShare",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "config",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "holding",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "issuerPubkey",
          "isMut": false,
          "isSigner": false,
          "docs": [
            "CHECK issuer pubkey"
          ]
        },
        {
          "name": "signer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "bump",
          "type": "u8"
        },
        {
          "name": "configBump",
          "type": "u8"
        }
      ]
    },
    {
      "name": "buyHoldings",
      "accounts": [
        {
          "name": "issuerShare",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "holding",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "vault",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK vault"
          ]
        },
        {
          "name": "issuerPubkey",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK issuer pubkey"
          ]
        },
        {
          "name": "config",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK admin key checked with config"
          ]
        },
        {
          "name": "signer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "bump",
          "type": "u8"
        },
        {
          "name": "vaultBump",
          "type": "u8"
        },
        {
          "name": "configBump",
          "type": "u8"
        },
        {
          "name": "oldShare",
          "type": "u16"
        },
        {
          "name": "k",
          "type": "u64"
        }
      ]
    },
    {
      "name": "sellHoldings",
      "accounts": [
        {
          "name": "issuerShare",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "holding",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "vault",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK vault"
          ]
        },
        {
          "name": "issuerPubkey",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK issuer pubkey"
          ]
        },
        {
          "name": "config",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK admin key checked with config"
          ]
        },
        {
          "name": "signer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "bump",
          "type": "u8"
        },
        {
          "name": "vaultBump",
          "type": "u8"
        },
        {
          "name": "configBump",
          "type": "u8"
        },
        {
          "name": "oldShare",
          "type": "u16"
        },
        {
          "name": "k",
          "type": "u64"
        }
      ]
    }
  ],
  "accounts": [
    {
      "name": "config",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "admin",
            "type": "publicKey"
          }
        ]
      }
    },
    {
      "name": "holding",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "shares",
            "type": "u16"
          }
        ]
      }
    },
    {
      "name": "issuerShare",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "issuer",
            "type": "publicKey"
          },
          {
            "name": "socialMediaHandle",
            "type": "publicKey"
          },
          {
            "name": "shares",
            "type": "u16"
          },
          {
            "name": "bump",
            "type": "u8"
          }
        ]
      }
    }
  ],
  "errors": [
    {
      "code": 6000,
      "name": "TodoNotFound",
      "msg": "The todo with the given id is not found"
    },
    {
      "code": 6001,
      "name": "TodoAlreadyCompleted",
      "msg": "The todo is already completed"
    }
  ]
};

export const IDL: FriendTech = {
  "version": "0.1.0",
  "name": "friend_tech",
  "instructions": [
    {
      "name": "initialize",
      "accounts": [
        {
          "name": "config",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "signer",
          "isMut": true,
          "isSigner": true,
          "docs": [
            "Solana Stuff"
          ]
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "bump",
          "type": "u8"
        }
      ]
    },
    {
      "name": "initIssuerShare",
      "accounts": [
        {
          "name": "issuerShare",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "config",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "issuerPubkey",
          "isMut": false,
          "isSigner": false,
          "docs": [
            "CHECK issuer pubkey"
          ]
        },
        {
          "name": "socialMediaHandle",
          "isMut": false,
          "isSigner": false,
          "docs": [
            "CHECK social media pda"
          ]
        },
        {
          "name": "signer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "bump",
          "type": "u8"
        },
        {
          "name": "configBump",
          "type": "u8"
        }
      ]
    },
    {
      "name": "initIssuerHolding",
      "accounts": [
        {
          "name": "issuerShare",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "config",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "holding",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "issuerPubkey",
          "isMut": false,
          "isSigner": false,
          "docs": [
            "CHECK issuer pubkey"
          ]
        },
        {
          "name": "signer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "bump",
          "type": "u8"
        },
        {
          "name": "configBump",
          "type": "u8"
        }
      ]
    },
    {
      "name": "buyHoldings",
      "accounts": [
        {
          "name": "issuerShare",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "holding",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "vault",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK vault"
          ]
        },
        {
          "name": "issuerPubkey",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK issuer pubkey"
          ]
        },
        {
          "name": "config",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK admin key checked with config"
          ]
        },
        {
          "name": "signer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "bump",
          "type": "u8"
        },
        {
          "name": "vaultBump",
          "type": "u8"
        },
        {
          "name": "configBump",
          "type": "u8"
        },
        {
          "name": "oldShare",
          "type": "u16"
        },
        {
          "name": "k",
          "type": "u64"
        }
      ]
    },
    {
      "name": "sellHoldings",
      "accounts": [
        {
          "name": "issuerShare",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "holding",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "vault",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK vault"
          ]
        },
        {
          "name": "issuerPubkey",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK issuer pubkey"
          ]
        },
        {
          "name": "config",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "admin",
          "isMut": true,
          "isSigner": false,
          "docs": [
            "CHECK admin key checked with config"
          ]
        },
        {
          "name": "signer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "bump",
          "type": "u8"
        },
        {
          "name": "vaultBump",
          "type": "u8"
        },
        {
          "name": "configBump",
          "type": "u8"
        },
        {
          "name": "oldShare",
          "type": "u16"
        },
        {
          "name": "k",
          "type": "u64"
        }
      ]
    }
  ],
  "accounts": [
    {
      "name": "config",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "admin",
            "type": "publicKey"
          }
        ]
      }
    },
    {
      "name": "holding",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "shares",
            "type": "u16"
          }
        ]
      }
    },
    {
      "name": "issuerShare",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "issuer",
            "type": "publicKey"
          },
          {
            "name": "socialMediaHandle",
            "type": "publicKey"
          },
          {
            "name": "shares",
            "type": "u16"
          },
          {
            "name": "bump",
            "type": "u8"
          }
        ]
      }
    }
  ],
  "errors": [
    {
      "code": 6000,
      "name": "TodoNotFound",
      "msg": "The todo with the given id is not found"
    },
    {
      "code": 6001,
      "name": "TodoAlreadyCompleted",
      "msg": "The todo is already completed"
    }
  ]
};
