# Anchor Todo List

There are 2 versions

- simple todo list: each todo list is a stored in a regular account owned by the todo list contract.
- complex todo list: each todo list is a stored in a PDA account owned by the todo list contract.
  - Each user has a `UserTodoListCounter` struct in a regular account owned by the todo list contract, we use the counter as the seed to generate new PDA for new todo list of the user.
