import {
  web3,
  Program,
  AnchorProvider,
  getProvider,
  setProvider,
  workspace,
} from '@coral-xyz/anchor';
import { SimpleTodoList } from '../target/types/simple_todo_list';

describe('test', () => {
  // Configure the client to use the local cluster.
  const provider = AnchorProvider.env();
  setProvider(provider);
  const programWallet = provider.wallet;

  const program = workspace.SimpleTodoList as Program<SimpleTodoList>;
  console.log('program wallet public key', programWallet.publicKey.toBase58());

  const user1 = web3.Keypair.generate();
  console.log('User 1 public key', user1.publicKey.toBase58());

  const conn = getProvider().connection;

  it('Creates a todo list', async () => {
    await conn
      .requestAirdrop(user1.publicKey, web3.LAMPORTS_PER_SOL)
      .then((sig) => conn.confirmTransaction(sig));
    await conn
      .requestAirdrop(program.provider.publicKey, web3.LAMPORTS_PER_SOL)
      .then((sig) => conn.confirmTransaction(sig));

    // =========================== Initialize the program ===========================

    await program.methods
      .initialize()
      .rpc()
      .then((tx) => {
        console.log('Todo list program initialized transaction signature', tx);
      });

    // =========================== user 1 creates a todo list ===========================

    const todoListKeypair = web3.Keypair.generate();
    console.log('Todo list keypair', todoListKeypair.publicKey.toBase58());

    await program.methods
      .createTodoList()
      .accounts({
        // since we let anchor generate the todo list account
        // we need to pass a ref so we can fetch it later
        todoList: todoListKeypair.publicKey,
        user: user1.publicKey,
      })
      .signers([user1, todoListKeypair])
      .rpc()
      .then((tx) => {
        console.log('User 1 created todo list transaction signature', tx);
      });

    // read the todo list of user 1
    await program.account.todoList
      .fetch(todoListKeypair.publicKey)
      .then((todoList) => {
        expect(todoList.owner.toBase58()).toEqual(user1.publicKey.toBase58());
        expect(todoList.todos.length).toEqual(0);
      });

    // =========================== user 1 creates a todo ===========================

    await program.methods
      .createTodo('todo 1')
      .accounts({
        todoList: todoListKeypair.publicKey,
        owner: user1.publicKey,
      })
      .signers([user1])
      .rpc()
      .then((tx) => {
        console.log('User 1 created todo transaction signature', tx);
      });

    // read the todo list of user 1
    await program.account.todoList
      .fetch(todoListKeypair.publicKey)
      .then((todoListWithTodo) => {
        expect(todoListWithTodo.todos.length).toEqual(1);

        // read the todo
        const todo = todoListWithTodo.todos[0];
        expect(todo.content).toEqual('todo 1');
        expect(todo.completed).toEqual(false);
      });

    // =========================== user 1 completes a todo ===========================

    await program.methods
      .completeTodo(0)
      .accounts({
        todoList: todoListKeypair.publicKey,
        owner: user1.publicKey,
      })
      .signers([user1])
      .rpc()
      .then((tx) => {
        console.log('User 1 completed todo transaction signature', tx);
      });

    // read the todo list of user 1
    await program.account.todoList
      .fetch(todoListKeypair.publicKey)
      .then((todoListWithCompletedTodo) => {
        expect(todoListWithCompletedTodo.todos.length).toEqual(1);

        // read the todo
        const completedTodo = todoListWithCompletedTodo.todos[0];
        expect(completedTodo.content).toEqual('todo 1');
        expect(completedTodo.completed).toEqual(true);
      });

    // =========================== user 1 creates another todo list ===========================

    const anotherTodoListKeypair = web3.Keypair.generate();
    console.log(
      'Another todo list keypair',
      anotherTodoListKeypair.publicKey.toBase58()
    );

    await program.methods
      .createTodoList()
      .accounts({
        todoList: anotherTodoListKeypair.publicKey,
        user: user1.publicKey,
      })
      .signers([user1, anotherTodoListKeypair])
      .rpc()
      .then((tx) => {
        console.log(
          'User 1 created another todo list transaction signature',
          tx
        );
      });

    // read the other todo list of user 1
    await program.account.todoList
      .fetch(anotherTodoListKeypair.publicKey)
      .then((todoList) => {
        expect(todoList.owner.toBase58()).toEqual(user1.publicKey.toBase58());
        expect(todoList.todos.length).toEqual(0);
      });
  });
});
