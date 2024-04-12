use anchor_lang::prelude::*;

#[account]
#[derive(InitSpace)]
pub struct TokenList {
    #[max_len(10000)] // Reserve space for up to 10000 tokens
    pub tokens: Vec<Pubkey>,
}
