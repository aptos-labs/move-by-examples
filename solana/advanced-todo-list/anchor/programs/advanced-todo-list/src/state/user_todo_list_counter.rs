use anchor_lang::prelude::*;

#[account]
#[derive(InitSpace)] // automatically calculate the space required for the struct
pub struct UserTodoListCounter {
    pub owner: Pubkey, // The owner of the account
    pub counter: u64,  // A counter for owner's TodoList PDAs
}
