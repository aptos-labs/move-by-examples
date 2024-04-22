use anchor_lang::prelude::*;

#[derive(Accounts)]
pub struct Initialize {}

pub fn handle_initialize(_ctx: Context<Initialize>) -> Result<()> {
    Ok(())
}
