use crate::state::Config;
use anchor_lang::prelude::*;

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, seeds = [b"config"], bump, payer = signer, space = std::mem::size_of::< Config > () + 8)]
    pub config: Account<'info, Config>,
    /// Solana Stuff
    #[account(mut)]
    pub signer: Signer<'info>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

pub fn handle_initialize(ctx: Context<Initialize>) -> Result<()> {
    ctx.accounts.config.admin = ctx.accounts.signer.key();
    Ok(())
}
