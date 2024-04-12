use anchor_lang::prelude::*;

#[error_code]
pub enum ContractError {
    #[msg("The todo with the given id is not found")]
    TodoNotFound,
    #[msg("The todo is already completed")]
    TodoAlreadyCompleted,
}
