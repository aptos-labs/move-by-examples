use crate::state::{Todo, TodoList};
use anchor_lang::prelude::*;

#[derive(Accounts)]
pub struct CreateTodo<'info> {
    #[account(mut, has_one = owner)]
    pub todo_list: Account<'info, TodoList>,
    pub owner: Signer<'info>,
}

pub fn handle_create_todo(ctx: Context<CreateTodo>, content: String) -> Result<()> {
    let todo_list = &mut ctx.accounts.todo_list;
    let todo = Todo {
        content,
        completed: false,
    };
    todo_list.todos.push(todo);
    Ok(())
}
