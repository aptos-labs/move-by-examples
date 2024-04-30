use crate::state::{Config, Holding, Issuer};
use anchor_lang::prelude::*;

#[derive(Accounts, Clone)]
pub struct IssueKey<'info> {
    #[account(init, seeds = [b"issuer", issuer_pubkey.key.as_ref()], bump, payer = signer, space = std::mem::size_of::< Issuer > () + 8)]
    pub issuer: Account<'info, Issuer>,
    #[account(seeds = [b"config"], bump)]
    pub config: Account<'info, Config>,
    #[account(init, seeds = [b"holding", issuer_pubkey.key.as_ref(), issuer_pubkey.key.as_ref()], bump, payer = signer, space = std::mem::size_of::< Holding > () + 8)]
    pub holding: Account<'info, Holding>,
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

pub fn handle_issue_key(ctx: Context<IssueKey>, bump: u8) -> Result<()> {
    ctx.accounts.issuer.issuer = ctx.accounts.issuer_pubkey.key();
    ctx.accounts.issuer.social_media_handle = ctx.accounts.social_media_handle.key();
    ctx.accounts.issuer.bump = bump;
    ctx.accounts.holding.shares = 1;
    ctx.accounts.issuer.shares = 1;
    Ok(())
}
