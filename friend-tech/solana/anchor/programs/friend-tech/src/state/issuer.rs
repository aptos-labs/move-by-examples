use anchor_lang::prelude::*;

#[account]
#[derive(Default)]
pub struct Issuer {
    pub issuer: Pubkey,
    pub username: String,
    pub shares: u16,
    pub bump: u8,
}
