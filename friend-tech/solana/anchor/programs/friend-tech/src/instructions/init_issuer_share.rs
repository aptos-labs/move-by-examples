use crate::state::{Config, IssuerShare};
use anchor_lang::prelude::*;

#[derive(Accounts, Clone)]
#[instruction(bump: u8, config_bump: u8)]
pub struct InitIssuerShare<'info> {
    #[account(init, seeds = [b"issuer_share", issuer_pubkey.key.as_ref()], bump, payer = signer, space = std::mem::size_of::< IssuerShare > () + 8)]
    pub issuer_share: Account<'info, IssuerShare>,
    #[account(seeds = [b"config"], bump = config_bump)]
    pub config: Account<'info, Config>,
    /// CHECK issuer pubkey
    pub issuer_pubkey: AccountInfo<'info>,
    /// CHECK social media pda
    pub social_media_handle: AccountInfo<'info>,
    // Solana stuff
    #[account(mut, constraint = signer.key().as_ref() == config.admin.key().as_ref())]
    pub signer: Signer<'info>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

pub fn handle_init_issuer_share(ctx: Context<InitIssuerShare>, bump: u8) -> Result<()> {
    ctx.accounts.issuer_share.issuer = ctx.accounts.issuer_pubkey.key();
    ctx.accounts.issuer_share.social_media_handle = ctx.accounts.social_media_handle.key();
    ctx.accounts.issuer_share.bump = bump;
    Ok(())
}
