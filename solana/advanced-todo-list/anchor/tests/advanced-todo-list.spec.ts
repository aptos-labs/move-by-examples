import {
  web3,
  Program,
  AnchorProvider,
  getProvider,
  setProvider,
  workspace,
  BN,
} from '@coral-xyz/anchor';
import { AdvancedTodoList } from '../target/types/advanced_todo_list';

describe('test', () => {
  // Configure the client to use the local cluster.
  const provider = AnchorProvider.env();
  setProvider(provider);
  const programWallet = provider.wallet;

  const program = workspace.AdvancedTodoList as Program<AdvancedTodoList>;
  console.log('program wallet public key', programWallet.publicKey.toBase58());

  const user1 = web3.Keypair.generate();
  console.log('User 1 public key', user1.publicKey.toBase58());

  const conn = getProvider().connection;

  it('Creates a todo list', async () => {
    await conn
      .requestAirdrop(user1.publicKey, web3.LAMPORTS_PER_SOL)
      .then((sig) => conn.confirmTransaction(sig));
    await conn
      .requestAirdrop(program.provider.publicKey!, web3.LAMPORTS_PER_SOL)
      .then((sig) => conn.confirmTransaction(sig));

    // =========================== Initialize the program ===========================

    await program.methods
      .initialize()
      .rpc()
      .then((tx) => {
        console.log('Todo list program initialized transaction signature', tx);
      });

    // === user 1 creates a todo list counter used as PDA seed to store todo lists ===

    const user1TodoListCounterKeypair = web3.Keypair.generate();
    console.log(
      'User 1 todo list counter keypair',
      user1TodoListCounterKeypair.publicKey.toBase58()
    );

    await program.methods
      .createUserTodoListCounter()
      .accounts({
        // since we let anchor generate the todo list counter account
        // we need to pass a ref so we can fetch it later
        userTodoListCounter: user1TodoListCounterKeypair.publicKey,
        user: user1.publicKey,
      })
      .signers([user1, user1TodoListCounterKeypair])
      .rpc()
      .then((tx) => {
        console.log(
          'User 1 created user todo list counter transaction signature',
          tx
        );
      });

    // read the todo list counter of user 1
    const user1TodoListCounter = await program.account.userTodoListCounter
      .fetch(user1TodoListCounterKeypair.publicKey)
      .then((counter) => {
        expect(counter.owner.toBase58()).toEqual(user1.publicKey.toBase58());
        expect(counter.counter.toString()).toEqual('0');
        return counter;
      });

    // =========================== user 1 creates a todo list ===========================

    const [todoList1Pda, _bump1] = web3.PublicKey.findProgramAddressSync(
      [
        user1.publicKey.toBuffer(),
        new BN(user1TodoListCounter.counter).toArrayLike(Buffer, 'le', 8), // Ensure the counter is 8 bytes
      ],
      program.programId
    );

    await program.methods
      .createTodoList()
      .accounts({
        todoList: todoList1Pda,
        userTodoListCounter: user1TodoListCounterKeypair.publicKey,
        user: user1.publicKey,
      })
      .signers([user1])
      .rpc()
      .then((tx) => {
        console.log('User 1 created todo list transaction signature', tx);
      });

    // read the todo list of user 1
    await program.account.todoList.fetch(todoList1Pda).then((todoList) => {
      expect(todoList.owner.toBase58()).toEqual(user1.publicKey.toBase58());
      expect(todoList.todos.length).toEqual(0);
    });

    // read the todo list counter of user 1
    await program.account.userTodoListCounter
      .fetch(user1TodoListCounterKeypair.publicKey)
      .then((counter) => {
        expect(counter.owner.toBase58()).toEqual(user1.publicKey.toBase58());
        expect(counter.counter.toString()).toEqual('1');
      });

    // =========================== user 1 creates a todo ===========================

    await program.methods
      .createTodo('todo 1')
      .accounts({
        todoList: todoList1Pda,
        owner: user1.publicKey,
      })
      .signers([user1])
      .rpc()
      .then((tx) => {
        console.log('User 1 created todo transaction signature', tx);
      });

    // read the todo list of user 1
    await program.account.todoList.fetch(todoList1Pda).then((todoList) => {
      expect(todoList.todos.length).toEqual(1);

      // read the todo
      const todo = todoList.todos[0];
      expect(todo.content).toEqual('todo 1');
      expect(todo.completed).toEqual(false);
    });

    // =========================== user 1 completes a todo ===========================

    await program.methods
      .completeTodo(0)
      .accounts({
        todoList: todoList1Pda,
        owner: user1.publicKey,
      })
      .signers([user1])
      .rpc()
      .then((tx) => {
        console.log('User 1 completed todo transaction signature', tx);
      });

    // read the todo list of user 1
    await program.account.todoList.fetch(todoList1Pda).then((todoList) => {
      expect(todoList.todos.length).toEqual(1);

      // read the todo
      const completedTodo = todoList.todos[0];
      expect(completedTodo.content).toEqual('todo 1');
      expect(completedTodo.completed).toEqual(true);
    });

    // =========================== user 1 creates another todo list ======================

    // read the todo list counter of user 1
    const user1TodoListCounter2 = await program.account.userTodoListCounter
      .fetch(user1TodoListCounterKeypair.publicKey)
      .then((counter) => {
        expect(counter.owner.toBase58()).toEqual(user1.publicKey.toBase58());
        expect(counter.counter.toString()).toEqual('1');
        return counter;
      });

    const [todoList2Pda, _bump2] = web3.PublicKey.findProgramAddressSync(
      [
        user1.publicKey.toBuffer(),
        new BN(user1TodoListCounter2.counter).toArrayLike(Buffer, 'le', 8), // Ensure the counter is 8 bytes
      ],
      program.programId
    );

    await program.methods
      .createTodoList()
      .accounts({
        todoList: todoList2Pda,
        userTodoListCounter: user1TodoListCounterKeypair.publicKey,
        user: user1.publicKey,
      })
      .signers([user1])
      .rpc()
      .then((tx) => {
        console.log(
          'User 1 created another todo list transaction signature',
          tx
        );
      });

    // read the todo list of user 1
    await program.account.todoList.fetch(todoList2Pda).then((todoList) => {
      expect(todoList.owner.toBase58()).toEqual(user1.publicKey.toBase58());
      expect(todoList.todos.length).toEqual(0);
    });

    // read the todo list counter of user 1
    await program.account.userTodoListCounter
      .fetch(user1TodoListCounterKeypair.publicKey)
      .then((counter) => {
        expect(counter.owner.toBase58()).toEqual(user1.publicKey.toBase58());
        expect(counter.counter.toString()).toEqual('2');
      });

    // =========================== user 1 creates a todo ===========================

    await program.methods
      .createTodo('todo 1')
      .accounts({
        todoList: todoList2Pda,
        owner: user1.publicKey,
      })
      .signers([user1])
      .rpc()
      .then((tx) => {
        console.log('User 1 created todo transaction signature', tx);
      });

    // read the todo list of user 1
    await program.account.todoList.fetch(todoList2Pda).then((todoList) => {
      expect(todoList.todos.length).toEqual(1);

      // read the todo
      const todo = todoList.todos[0];
      expect(todo.content).toEqual('todo 1');
      expect(todo.completed).toEqual(false);
    });

    // =========================== user 1 completes a todo ===========================

    await program.methods
      .completeTodo(0)
      .accounts({
        todoList: todoList2Pda,
        owner: user1.publicKey,
      })
      .signers([user1])
      .rpc()
      .then((tx) => {
        console.log('User 1 completed another todo transaction signature', tx);
      });

    // read the todo list of user 1
    await program.account.todoList.fetch(todoList1Pda).then((todoList) => {
      expect(todoList.todos.length).toEqual(1);

      // read the todo
      const completedTodo2 = todoList.todos[0];
      expect(completedTodo2.content).toEqual('todo 1');
      expect(completedTodo2.completed).toEqual(true);
    });
  });
});
