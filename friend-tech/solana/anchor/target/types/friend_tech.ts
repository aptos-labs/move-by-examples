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
      "args": []
    },
    {
      "name": "issueKey",
      "accounts": [
        {
          "name": "issuer",
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
          "name": "username",
          "type": "string"
        }
      ]
    },
    {
      "name": "buyKey",
      "accounts": [
        {
          "name": "issuer",
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
          "name": "k",
          "type": "u64"
        }
      ]
    },
    {
      "name": "sellKey",
      "accounts": [
        {
          "name": "issuer",
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
          "name": "vaultBump",
          "type": "u8"
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
      "name": "issuer",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "issuer",
            "type": "publicKey"
          },
          {
            "name": "username",
            "type": "string"
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
      "args": []
    },
    {
      "name": "issueKey",
      "accounts": [
        {
          "name": "issuer",
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
          "name": "username",
          "type": "string"
        }
      ]
    },
    {
      "name": "buyKey",
      "accounts": [
        {
          "name": "issuer",
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
          "name": "k",
          "type": "u64"
        }
      ]
    },
    {
      "name": "sellKey",
      "accounts": [
        {
          "name": "issuer",
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
          "name": "vaultBump",
          "type": "u8"
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
      "name": "issuer",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "issuer",
            "type": "publicKey"
          },
          {
            "name": "username",
            "type": "string"
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
  ]
};
