# Example Contracts on Solana using Anchor

You can find the overview of all contracts in the root directory's readme.

Some Solana specific things here:

- simple todo list: each todo list is a stored in a regular account owned by the todo list contract.
- advanced todo list: each todo list is a stored in a PDA account owned by the todo list contract, each user has a `UserTodoListCounter` struct in a regular account owned by the todo list contract. We use the counter as the seed to generate new PDA for new todo list of the user.
- token launchpad: mint authority is controlled by PDA to enable permissionless mint.
