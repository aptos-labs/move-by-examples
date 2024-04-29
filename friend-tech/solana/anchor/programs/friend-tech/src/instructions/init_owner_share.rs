use crate::state::{Config, OwnerShare};
use anchor_lang::prelude::*;

#[derive(Accounts, Clone)]
#[instruction(bump: u8, config_bump: u8)]
pub struct InitOwnerShare<'info> {
    #[account(init, seeds = [b"owner_share", owner_pubkey.key.as_ref()], bump, payer = signer, space = std::mem::size_of::< OwnerShare > () + 8)]
    pub owner_share: Account<'info, OwnerShare>,
    #[account(seeds = [b"config"], bump = config_bump)]
    pub config: Account<'info, Config>,
    /// CHECK owner pubkey
    pub owner_pubkey: AccountInfo<'info>,
    /// CHECK social media pda
    pub social_media_handle: AccountInfo<'info>,
    // Solana stuff
    #[account(mut, constraint = signer.key().as_ref() == config.admin.key().as_ref())]
    pub signer: Signer<'info>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

pub fn handle_init_owner_share(ctx: Context<InitOwnerShare>, bump: u8) -> Result<()> {
    ctx.accounts.owner_share.owner = ctx.accounts.owner_pubkey.key();
    ctx.accounts.owner_share.social_media_handle = ctx.accounts.social_media_handle.key();
    ctx.accounts.owner_share.bump = bump;
    Ok(())
}
