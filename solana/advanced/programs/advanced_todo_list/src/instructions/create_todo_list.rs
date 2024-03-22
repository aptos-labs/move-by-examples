use crate::state::{TodoList, UserTodoListCounter};
use anchor_lang::prelude::*;

#[derive(Accounts)]
pub struct CreateTodoList<'info> {
    #[account(init, payer = user, space = 10240, seeds = [user.key().as_ref(), user_todo_list_counter.counter.to_le_bytes().as_ref()], bump)]
    pub todo_list: Account<'info, TodoList>,
    #[account(mut)]
    pub user: Signer<'info>,
    #[account(mut)]
    pub user_todo_list_counter: Account<'info, UserTodoListCounter>,
    pub system_program: Program<'info, System>,
}

pub fn handle_create_todo_list(ctx: Context<CreateTodoList>) -> Result<()> {
    let user_todo_list_counter = &mut ctx.accounts.user_todo_list_counter;
    let todo_list = &mut ctx.accounts.todo_list;

    // Set the TodoList fields
    todo_list.owner = *ctx.accounts.user.key;
    todo_list.todos = Vec::new();

    // Increment the user's counter for the next TodoList
    user_todo_list_counter.counter = user_todo_list_counter.counter.checked_add(1).unwrap();
    Ok(())
}
