use anchor_lang::prelude::*;
use instructions::*;
mod error;
mod instructions;
mod state;

declare_id!("AoFCssRtKUgXfhwb2T4F3jLenCZaSxmkAwrZAL9SQB9G");

#[program]
pub mod simple_todo_list {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        handle_initialize(ctx)
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
