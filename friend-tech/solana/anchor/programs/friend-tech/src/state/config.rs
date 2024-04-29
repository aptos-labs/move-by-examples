use anchor_lang::prelude::*;

#[account]
#[derive(Default)]
pub struct Config {
    pub admin: Pubkey,
}
