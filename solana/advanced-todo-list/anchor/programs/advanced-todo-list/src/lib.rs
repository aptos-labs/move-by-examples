use anchor_lang::prelude::*;
use instructions::*;
mod error;
mod instructions;
mod state;

declare_id!("CpdzsbyuX6ZpS37LqtN5qL4SXSz2LXzz7mckgYQupJ3V");

#[program]
pub mod advanced_todo_list {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        handle_initialize(ctx)
    }

    // need to be called once per user before creating a TodoList
    pub fn create_user_todo_list_counter(ctx: Context<CreateUserTodoListCounter>) -> Result<()> {
        handle_create_user_todo_list_counter(ctx)
    }

    pub fn create_todo_list(ctx: Context<CreateTodoList>) -> Result<()> {
        handle_create_todo_list(ctx)
    }

    pub fn create_todo(ctx: Context<CreateTodo>, content: String) -> Result<()> {
        handle_create_todo(ctx, content)
    }

    pub fn complete_todo(ctx: Context<CompleteTodo>, index: u32) -> Result<()> {
        handle_complete_todo(ctx, index)
    }
}
