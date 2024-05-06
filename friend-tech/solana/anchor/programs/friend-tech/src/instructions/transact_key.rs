use crate::state::{Config, Holding, Issuer};
use anchor_lang::{prelude::*, solana_program::native_token::LAMPORTS_PER_SOL};

#[derive(Accounts, Clone)]
pub struct TransactHoldings<'info> {
    #[account(mut, seeds = [b"issuer", issuer_pubkey.key.as_ref()], bump = issuer.bump)]
    pub issuer: Account<'info, Issuer>,
    #[account(init_if_needed, seeds = [b"holding", issuer_pubkey.key.as_ref(), signer.key.as_ref()], bump, payer = signer, space = std::mem::size_of::< Holding > () + 8)]
    pub holding: Account<'info, Holding>,
    /// CHECK vault
    #[account(mut, seeds = [b"vault"], bump)]
    pub vault: AccountInfo<'info>,
    /// CHECK issuer pubkey
    #[account(mut)]
    pub issuer_pubkey: AccountInfo<'info>,
    #[account(seeds = [b"config"], bump)]
    pub config: Account<'info, Config>,
    /// CHECK admin key checked with config
    #[account(mut, constraint = admin.key().as_ref() == config.admin.key().as_ref())]
    pub admin: AccountInfo<'info>,
    #[account(mut)]
    pub signer: Signer<'info>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

pub fn handle_buy_key(ctx: Context<TransactHoldings>, k: u64) -> Result<()> {
    msg!("current share {}", ctx.accounts.issuer.shares);
    let old_share = ctx.accounts.issuer.shares;

    let supply = old_share as u64;
    let temp1 = supply.clone().checked_sub(1).unwrap();
    let temp2 = (2 as u64)
        .checked_mul(temp1.clone())
        .unwrap()
        .checked_add(1)
        .unwrap();

    let sum1 = temp1
        .clone()
        .checked_mul(supply)
        .unwrap()
        .checked_mul(temp2)
        .unwrap()
        .checked_div(6)
        .unwrap();

    let temp3 = temp1.checked_add(k.clone()).unwrap();
    let temp4 = supply.clone().checked_add(k.clone()).unwrap();
    let temp5 = (2 as u64)
        .checked_mul(temp3.clone())
        .unwrap()
        .checked_add(1)
        .unwrap();

    let sum2 = temp3
        .checked_mul(temp4)
        .unwrap()
        .checked_mul(temp5)
        .unwrap()
        .checked_div(6)
        .unwrap();
    let summation: u64 = (sum2.checked_sub(sum1)).unwrap() as u64;
    let price = (summation * LAMPORTS_PER_SOL).checked_div(16000).unwrap();
    let issuer_fee = price
        .checked_mul(50000000)
        .unwrap()
        .checked_div(LAMPORTS_PER_SOL)
        .unwrap();
    let protocol_fee = price
        .checked_mul(50000000)
        .unwrap()
        .checked_div(LAMPORTS_PER_SOL)
        .unwrap();

    {
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &ctx.accounts.signer.key(),
            &ctx.accounts.vault.key(),
            price,
        );

        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                ctx.accounts.signer.to_account_info(),
                ctx.accounts.vault.to_account_info(),
            ],
        )?;
        msg!("transferred {} as price for key", price);
    }

    {
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &ctx.accounts.signer.key(),
            &ctx.accounts.issuer_pubkey.key(),
            issuer_fee,
        );

        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                ctx.accounts.signer.to_account_info(),
                ctx.accounts.issuer_pubkey.to_account_info(),
            ],
        )?;
        msg!("transferred {} as issuer fee for key", issuer_fee);
    }

    {
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &ctx.accounts.signer.key(),
            &ctx.accounts.admin.key(),
            protocol_fee,
        );

        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                ctx.accounts.signer.to_account_info(),
                ctx.accounts.admin.to_account_info(),
            ],
        )?;
        msg!("transferred {} as protocol fee for key", protocol_fee);
    }

    msg!("price {} supply {} k {}", price, old_share, k);
    ctx.accounts.issuer.shares = ctx
        .accounts
        .issuer
        .shares
        .checked_add(k.clone() as u16)
        .unwrap();
    ctx.accounts.holding.shares = ctx
        .accounts
        .holding
        .shares
        .checked_add(k.clone() as u16)
        .unwrap();
    Ok(())
}

pub fn handle_sell_key(ctx: Context<TransactHoldings>, vault_bump: u8, k: u64) -> Result<()> {
    msg!("current share {}", ctx.accounts.issuer.shares);
    let old_share = ctx.accounts.issuer.shares;
    if ctx.accounts.issuer.shares == 0 || ctx.accounts.holding.shares == 0 {
        msg!(
            "out of shares to sell, total {}, you own {} ",
            ctx.accounts.issuer.shares,
            ctx.accounts.holding.shares
        );
        panic!()
    }
    let supply = old_share as u64;
    let temp1 = supply.clone().checked_sub(1).unwrap();
    let temp2 = (2 as u64)
        .checked_mul(temp1.clone())
        .unwrap()
        .checked_add(1)
        .unwrap();

    let sum1 = temp1
        .clone()
        .checked_mul(supply)
        .unwrap()
        .checked_mul(temp2)
        .unwrap()
        .checked_div(6)
        .unwrap();

    let temp3 = temp1.checked_add(k.clone()).unwrap();
    let temp4 = supply.clone().checked_add(k.clone()).unwrap();
    let temp5 = (2 as u64)
        .checked_mul(temp3.clone())
        .unwrap()
        .checked_add(1)
        .unwrap();

    let sum2 = temp3
        .checked_mul(temp4)
        .unwrap()
        .checked_mul(temp5)
        .unwrap()
        .checked_div(6)
        .unwrap();
    let summation: u64 = (sum2.checked_sub(sum1)).unwrap() as u64;
    let price = (summation * LAMPORTS_PER_SOL).checked_div(16000).unwrap();

    let issuer_fee = price
        .checked_mul(50000000)
        .unwrap()
        .checked_div(LAMPORTS_PER_SOL)
        .unwrap();
    let protocol_fee = price
        .checked_mul(50000000)
        .unwrap()
        .checked_div(LAMPORTS_PER_SOL)
        .unwrap();
    let cpi_program = ctx.accounts.system_program.to_account_info();

    {
        let cpi_accounts = anchor_lang::system_program::Transfer {
            from: ctx.accounts.vault.to_account_info(),
            to: ctx.accounts.signer.to_account_info(),
        };

        let signature_seeds = [b"vault".as_ref(), &[vault_bump]];
        let signers = &[&signature_seeds[..]];

        let cpi_context = CpiContext::new_with_signer(cpi_program, cpi_accounts, signers);

        anchor_lang::system_program::transfer(cpi_context, price)?;
        msg!("pay out {} as price for key", price);
    }

    {
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &ctx.accounts.signer.key(),
            &ctx.accounts.issuer_pubkey.key(),
            issuer_fee,
        );

        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                ctx.accounts.signer.to_account_info(),
                ctx.accounts.issuer_pubkey.to_account_info(),
            ],
        )?;
        msg!("transferred {} as issuer fee for key", issuer_fee);
    }

    {
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &ctx.accounts.signer.key(),
            &ctx.accounts.admin.key(),
            protocol_fee,
        );

        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                ctx.accounts.signer.to_account_info(),
                ctx.accounts.admin.to_account_info(),
            ],
        )?;
        msg!("transferred {} as protocol_fee fee for key", protocol_fee);
    }

    msg!("price {} supply {} k {}", price, old_share, k);
    ctx.accounts.issuer.shares = ctx
        .accounts
        .issuer
        .shares
        .checked_sub(k.clone() as u16)
        .unwrap();
    ctx.accounts.holding.shares = ctx
        .accounts
        .holding
        .shares
        .checked_sub(k.clone() as u16)
        .unwrap();
    Ok(())
}
