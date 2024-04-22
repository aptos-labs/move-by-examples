use crate::state::Registry;
use anchor_lang::prelude::*;

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(mut)]
    pub payer: Signer<'info>,
    #[account(init, payer = payer, space = 10000)]
    pub registry: Account<'info, Registry>,
    pub system_program: Program<'info, System>,
}

pub fn handle_initialize(ctx: Context<Initialize>) -> Result<()> {
    let registry = &mut ctx.accounts.registry;
    registry.tokens = Vec::new();
    Ok(())
}
