use anchor_lang::prelude::*;

#[account]
#[derive(Default)]
pub struct IssuerShare {
    pub issuer: Pubkey,
    pub social_media_handle: Pubkey,
    pub shares: u16,
    pub bump: u8,
}
