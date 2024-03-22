use anchor_lang::prelude::*;
use crate::state::UserTodoListCounter;

#[derive(Accounts)]
pub struct CreateUserTodoListCounter<'info> {
    #[account(init, payer = user, space = 8 + 32 + 8)] // Adjust space as needed
    pub user_todo_list_counter: Account<'info, UserTodoListCounter>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

// need to be called once per user before creating a TodoList
pub fn handle_create_user_todo_list_counter(ctx: Context<CreateUserTodoListCounter>) -> Result<()> {
    let user_todo_list_counter = &mut ctx.accounts.user_todo_list_counter;
    user_todo_list_counter.owner = *ctx.accounts.user.key;
    user_todo_list_counter.counter = 0;
    Ok(())
}
