export type AdvancedTodoList = {
  "version": "0.1.0",
  "name": "advanced_todo_list",
  "instructions": [
    {
      "name": "initialize",
      "accounts": [],
      "args": []
    },
    {
      "name": "createUserTodoListCounter",
      "accounts": [
        {
          "name": "userTodoListCounter",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "user",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": []
    },
    {
      "name": "createTodoList",
      "accounts": [
        {
          "name": "todoList",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "user",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "userTodoListCounter",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": []
    },
    {
      "name": "createTodo",
      "accounts": [
        {
          "name": "todoList",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "owner",
          "isMut": false,
          "isSigner": true
        }
      ],
      "args": [
        {
          "name": "content",
          "type": "string"
        }
      ]
    },
    {
      "name": "completeTodo",
      "accounts": [
        {
          "name": "todoList",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "owner",
          "isMut": false,
          "isSigner": true
        }
      ],
      "args": [
        {
          "name": "index",
          "type": "u32"
        }
      ]
    }
  ],
  "accounts": [
    {
      "name": "todoList",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "owner",
            "type": "publicKey"
          },
          {
            "name": "todos",
            "type": {
              "vec": {
                "defined": "Todo"
              }
            }
          }
        ]
      }
    },
    {
      "name": "userTodoListCounter",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "owner",
            "type": "publicKey"
          },
          {
            "name": "counter",
            "type": "u64"
          }
        ]
      }
    }
  ],
  "types": [
    {
      "name": "Todo",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "content",
            "type": "string"
          },
          {
            "name": "completed",
            "type": "bool"
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

export const IDL: AdvancedTodoList = {
  "version": "0.1.0",
  "name": "advanced_todo_list",
  "instructions": [
    {
      "name": "initialize",
      "accounts": [],
      "args": []
    },
    {
      "name": "createUserTodoListCounter",
      "accounts": [
        {
          "name": "userTodoListCounter",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "user",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": []
    },
    {
      "name": "createTodoList",
      "accounts": [
        {
          "name": "todoList",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "user",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "userTodoListCounter",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": []
    },
    {
      "name": "createTodo",
      "accounts": [
        {
          "name": "todoList",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "owner",
          "isMut": false,
          "isSigner": true
        }
      ],
      "args": [
        {
          "name": "content",
          "type": "string"
        }
      ]
    },
    {
      "name": "completeTodo",
      "accounts": [
        {
          "name": "todoList",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "owner",
          "isMut": false,
          "isSigner": true
        }
      ],
      "args": [
        {
          "name": "index",
          "type": "u32"
        }
      ]
    }
  ],
  "accounts": [
    {
      "name": "todoList",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "owner",
            "type": "publicKey"
          },
          {
            "name": "todos",
            "type": {
              "vec": {
                "defined": "Todo"
              }
            }
          }
        ]
      }
    },
    {
      "name": "userTodoListCounter",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "owner",
            "type": "publicKey"
          },
          {
            "name": "counter",
            "type": "u64"
          }
        ]
      }
    }
  ],
  "types": [
    {
      "name": "Todo",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "content",
            "type": "string"
          },
          {
            "name": "completed",
            "type": "bool"
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
