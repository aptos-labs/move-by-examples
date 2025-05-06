# Voting Smart Contract

## Overview

This Move module implements a basic on-chain voting system on the Aptos blockchain. The voting contract allows users to create proposals, stake governance tokens, and vote on proposals using their staked tokens. The contract also includes functionality for users to unstake their tokens, with certain restrictions to prevent unstaking during live proposals.

## Key Components

### Proposals

- Each proposal has an ID, name, creator’s address, start and end times, and tallies of “yes” and “no” votes.
- Proposals are stored in a global `ProposalRegistry`.

### User Stake

- Users must stake governance tokens to participate in voting.
- Each user’s stake is managed by a `UserStake` object, which holds the staked token amount.

### Voting

- Users can vote on proposals using their staked tokens. A user’s vote is weighted by the amount of tokens they have staked.
- Votes are recorded in a `Vote` object, which stores the voter’s address, their vote (yes/no), and the number of tokens they used to vote.

### Controllers

- **FungibleStoreController:** Manages the fungible store used to transfer staked tokens.
- **UserStakeController:** Manages the creation and maintenance of user stakes.

## Main Functions

### Initialization

- `init_module`: Initializes the contract and creates necessary global objects such as `ProposalRegistry` and `FungibleAssetMetadata`.

### Proposal Management

- `create_proposal`: Allows users to create a new proposal, specifying a name and duration for the voting period.

### Voting

- `vote_on_proposal`: Allows users to cast a vote on a specific proposal using their staked tokens.

### Staking

- `stake`: Allows users to stake their tokens in order to participate in voting.
- `unstake`: Allows users to unstake their tokens, provided they have not voted on an active proposal.

### Read Functions

- `get_proposal`: Retrieves details of a specific proposal.
- `has_proposal_ended`: Checks whether a given proposal has ended.
- `get_proposal_result`: Returns the result of a proposal.
- `get_user_stake_amount`: Retrieves the amount of tokens a user has staked.