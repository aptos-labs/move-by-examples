use crate::state::TodoList;
use anchor_lang::prelude::*;

#[derive(Accounts)]
pub struct CreateTodoList<'info> {
    #[account(init, payer = user, space = 10240)]
    pub todo_list: Account<'info, TodoList>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

pub fn handle_create_todo_list(ctx: Context<CreateTodoList>) -> Result<()> {
    let todo_list = &mut ctx.accounts.todo_list;
    todo_list.owner = *ctx.accounts.user.key;
    todo_list.todos = Vec::new();
    Ok(())
}
