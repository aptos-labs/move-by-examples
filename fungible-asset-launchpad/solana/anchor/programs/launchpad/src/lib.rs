use anchor_lang::prelude::*;
use instructions::*;
mod instructions;
mod state;

declare_id!("7kUij7HeYodZGUGB1d1TQpHC3gxUqf4t6NQBf3QjVpru");

#[program]
pub mod launchpad {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        handle_initialize(ctx)
    }

    pub fn create_token(
        ctx: Context<CreateToken>,
        token_name: String,
        token_symbol: String,
        token_uri: String,
    ) -> Result<()> {
        handle_create_token(ctx, token_name, token_symbol, token_uri)
    }

    pub fn mint_token(ctx: Context<MintToken>, amount: u64) -> Result<()> {
        handle_mint_token(ctx, amount)
    }
}
