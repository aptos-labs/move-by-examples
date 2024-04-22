use crate::state::Registry;
use anchor_lang::prelude::*;
use anchor_spl::{
    metadata::{
        create_metadata_accounts_v3,
        mpl_token_metadata::{programs::MPL_TOKEN_METADATA_ID, types::DataV2},
        CreateMetadataAccountsV3, Metadata,
    },
    token::{Mint, Token},
};

#[derive(Accounts)]
pub struct CreateToken<'info> {
    #[account(mut)]
    pub payer: Signer<'info>,
    // Create mint account
    // Same PDA as address of the account and mint/freeze authority
    #[account(
        init,
        seeds = [b"mint"],
        bump,
        payer = payer,
        mint::decimals = 9,
        mint::authority = mint_account.key(),
        mint::freeze_authority = mint_account.key(),
    )]
    pub mint_account: Account<'info, Mint>,
    /// CHECK: Address validated using constraint
    #[account(
        mut,
        address=Pubkey::find_program_address(
        &[
            "metadata".as_bytes(),
            MPL_TOKEN_METADATA_ID.as_ref(),
            mint_account.key().as_ref(),
        ],
        &MPL_TOKEN_METADATA_ID,
    ).0
    )]
    pub metadata_account: UncheckedAccount<'info>,
    pub token_program: Program<'info, Token>,
    pub token_metadata_program: Program<'info, Metadata>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
    #[account(mut)]
    pub registry: Account<'info, Registry>,
}

pub fn handle_create_token(
    ctx: Context<CreateToken>,
    token_name: String,
    token_symbol: String,
    token_uri: String,
) -> Result<()> {
    msg!("Creating metadata account");

    let signer_seeds: &[&[&[u8]]] = &[&[b"mint", &[ctx.bumps.mint_account]]];

    create_metadata_accounts_v3(
        CpiContext::new_with_signer(
            ctx.accounts.token_metadata_program.to_account_info(),
            CreateMetadataAccountsV3 {
                metadata: ctx.accounts.metadata_account.to_account_info(),
                mint: ctx.accounts.mint_account.to_account_info(),
                mint_authority: ctx.accounts.mint_account.to_account_info(), // PDA is mint authority
                update_authority: ctx.accounts.mint_account.to_account_info(), // PDA is update authority
                payer: ctx.accounts.payer.to_account_info(),
                system_program: ctx.accounts.system_program.to_account_info(),
                rent: ctx.accounts.rent.to_account_info(),
            },
            signer_seeds,
        ),
        DataV2 {
            name: token_name,
            symbol: token_symbol,
            uri: token_uri,
            seller_fee_basis_points: 0,
            creators: None,
            collection: None,
            uses: None,
        },
        false,
        true,
        None,
    )?;

    msg!("Token created successfully.");

    let registry = &mut ctx.accounts.registry;
    registry.tokens.push(ctx.accounts.mint_account.key());

    Ok(())
}
