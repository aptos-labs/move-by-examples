use crate::state::{Config, Holding, OwnerShare};
use anchor_lang::prelude::*;

#[derive(Accounts, Clone)]
#[instruction(bump: u8, config_bump: u8)]
pub struct InitOwnerHolding<'info> {
    #[account(mut, seeds = [b"owner_share", owner_pubkey.key.as_ref()], bump)]
    pub owner_share: Account<'info, OwnerShare>,
    #[account(seeds = [b"config"], bump = config_bump)]
    pub config: Account<'info, Config>,
    #[account(init, seeds = [b"holding", owner_pubkey.key.as_ref(), owner_pubkey.key.as_ref()], bump, payer = signer, space = std::mem::size_of::< Holding > () + 8)]
    pub holding: Account<'info, Holding>,
    /// CHECK owner pubkey
    pub owner_pubkey: AccountInfo<'info>,
    #[account(mut, constraint = signer.key().as_ref() == config.admin.key().as_ref())]
    pub signer: Signer<'info>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

pub fn handle_init_owner_holding(ctx: Context<InitOwnerHolding>) -> Result<()> {
    ctx.accounts.holding.shares = 1;
    ctx.accounts.owner_share.shares = 1;
    Ok(())
}
