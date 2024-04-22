# Advanced Todo List

## Overview

Difference from simple todo list user can own multiple todo list contract.

## Aptos Specific Things

Each user can have multiple todo lists, each todo list is stored under an object owned by the user, this is similar to PDA on Solana.

## Solana Specific Things

Each todo list is a stored in a PDA account owned by the todo list contract, each user has a `UserTodoListCounter` struct in a regular account owned by the todo list contract. We use the counter as the seed to generate new PDA for new todo list of the user.
