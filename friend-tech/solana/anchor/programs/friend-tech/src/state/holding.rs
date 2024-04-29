use anchor_lang::prelude::*;

#[account]
#[derive(Default)]
pub struct Holding {
    pub shares: u16,
}
