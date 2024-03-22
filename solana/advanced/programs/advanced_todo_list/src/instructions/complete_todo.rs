use crate::error::*;
use crate::state::TodoList;
use anchor_lang::prelude::*;

#[derive(Accounts)]
pub struct CompleteTodo<'info> {
    #[account(mut, has_one = owner)]
    pub todo_list: Account<'info, TodoList>,
    pub owner: Signer<'info>,
}

pub fn handle_complete_todo(ctx: Context<CompleteTodo>, index: u32) -> Result<()> {
    let todo_list = &mut ctx.accounts.todo_list;
    require!(
        (index as usize) < todo_list.todos.len(),
        ContractError::TodoNotFound
    );
    require!(
        !todo_list.todos[index as usize].completed,
        ContractError::TodoAlreadyCompleted
    );
    todo_list.todos[index as usize].completed = true;
    Ok(())
}
