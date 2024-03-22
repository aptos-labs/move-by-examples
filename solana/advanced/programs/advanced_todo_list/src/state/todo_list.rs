use anchor_lang::prelude::*;

#[derive(AnchorSerialize, AnchorDeserialize, Clone, InitSpace)]
pub struct Todo {
    #[max_len(200)] // Reserve space for up to 50 characters, considering UTF-8 encoding
    pub content: String,
    pub completed: bool,
}

#[account]
#[derive(InitSpace)]
pub struct TodoList {
    pub owner: Pubkey,
    #[max_len(10)] // Reserve space for up to 10 todos
    pub todos: Vec<Todo>,
}
