#![allow(clippy::result_large_err)]

use instructions::*;
mod error;
mod instructions;
mod state;
use anchor_lang::prelude::*;

declare_id!("GcdUTgTLJ5TFQpD5r2Da8ogVnSCr8XBpmUxYdU2nzdK");

#[program]
pub mod friend_tech {

    use super::*;

    pub fn initialize(ctx: Context<Initialize>, _bump: u8) -> Result<()> {
        handle_initialize(ctx)
    }

    pub fn init_vault(ctx: Context<InitVault>) -> Result<()> {
        handle_init_vault(ctx)
    }

    pub fn init_owner_share(
        ctx: Context<InitOwnerShare>,
        bump: u8,
        _config_bump: u8,
    ) -> Result<()> {
        handle_init_owner_share(ctx, bump)
    }

    pub fn init_owner_holding(
        ctx: Context<InitOwnerHolding>,
        _bump: u8,
        _config_bump: u8,
    ) -> Result<()> {
        handle_init_owner_holding(ctx)
    }

    pub fn buy_holdings(
        ctx: Context<TransactHoldings>,
        _bump: u8,
        _vault_bump: u8,
        _config_bump: u8,
        old_share: u16,
        k: u64,
    ) -> Result<()> {
        handle_buy_holdings(ctx, old_share, k)
    }

    pub fn sell_holdings(
        ctx: Context<TransactHoldings>,
        _bump: u8,
        vault_bump: u8,
        _config_bump: u8,
        old_share: u16,
        k: u64,
    ) -> Result<()> {
        handle_sell_holdings(ctx, vault_bump, old_share, k)
    }
}
