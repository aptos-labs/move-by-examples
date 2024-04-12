use crate::state::TokenList;
use anchor_lang::prelude::*;

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(mut)]
    pub payer: Signer<'info>,
    #[account(init, payer = payer, space = 10000)]
    pub token_list: Account<'info, TokenList>,
    pub system_program: Program<'info, System>,
}

pub fn handle_initialize(ctx: Context<Initialize>) -> Result<()> {
    let token_list = &mut ctx.accounts.token_list;
    token_list.tokens = Vec::new();
    Ok(())
}
