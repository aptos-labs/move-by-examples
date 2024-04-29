use anchor_lang::prelude::*;

#[derive(Accounts)]
pub struct InitVault<'info> {
    /// Solana Stuff
    #[account(mut)]
    pub signer: Signer<'info>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

pub fn handle_init_vault(_ctx: Context<InitVault>) -> Result<()> {
    Ok(())
}
