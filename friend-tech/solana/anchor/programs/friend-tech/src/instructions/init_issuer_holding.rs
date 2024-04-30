use crate::state::{Config, Holding, IssuerShare};
use anchor_lang::prelude::*;

#[derive(Accounts, Clone)]
#[instruction(bump: u8, config_bump: u8)]
pub struct InitIssuerHolding<'info> {
    #[account(mut, seeds = [b"issuer_share", issuer_pubkey.key.as_ref()], bump)]
    pub issuer_share: Account<'info, IssuerShare>,
    #[account(seeds = [b"config"], bump = config_bump)]
    pub config: Account<'info, Config>,
    #[account(init, seeds = [b"holding", issuer_pubkey.key.as_ref(), issuer_pubkey.key.as_ref()], bump, payer = signer, space = std::mem::size_of::< Holding > () + 8)]
    pub holding: Account<'info, Holding>,
    /// CHECK issuer pubkey
    pub issuer_pubkey: AccountInfo<'info>,
    #[account(mut, constraint = signer.key().as_ref() == config.admin.key().as_ref())]
    pub signer: Signer<'info>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

pub fn handle_init_issuer_holding(ctx: Context<InitIssuerHolding>) -> Result<()> {
    ctx.accounts.holding.shares = 1;
    ctx.accounts.issuer_share.shares = 1;
    Ok(())
}
