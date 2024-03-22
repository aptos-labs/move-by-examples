module advanced_todo_list_addr::advanced_todo_list {
    use std::bcs::to_bytes;
    use std::signer;
    use std::vector;
    use std::string::String;
    use aptos_framework::object;

    // Errors
    const E_NOT_INITIALIZED: u64 = 1;
    const ETODO_DOESNT_EXIST: u64 = 2;
    const ETODO_IS_COMPLETED: u64 = 3;

    struct TodoList has key {
        owner: address,
        todos: vector<Todo>,
    }

    struct Todo has store, drop, copy {
        content: String,
        completed: bool,
    }

    struct UserTodoListCounter has store, drop, copy {
        counter: u64,
    }

    // This function is only called once when the module is published for the first time.
    fun init_module(_deployer: &signer) {
        // nothing to do here
    }

    public entry fun create_todo_list(account: &signer) acquires UserTodoListCounter {
        if (!exists<UserTodoListCounter>(signer::address_of(account))) {
            let counter = UserTodoListCounter {
                counter: 0,
            };
            move_to(account, counter);
        };
        let counter = borrow_global_mut<UserTodoListCounter>(signer::address_of(account));
        let obj = object::create_named_object(account, to_bytes(&counter.counter));
        let todo_list = TodoList {
            owner: signer::address_of(account),
            todos: vector::empty(),
        };
        let obj_signer = object::generate_signer(&obj);
        // move the TodoList resource under the object
        move_to(&obj_signer, todo_list);
        counter.counter = counter.counter + 1;
    }

    public entry fun create_todo(account: &signer, todo_list_idx: u64, content: String) acquires TodoList {
        // gets the signer address
        let todo_list_object_addr = object::create_object_address(&signer::address_of(account), to_bytes(&todo_list_idx));
        // assert signer has created a list
        assert!(exists<TodoList>(todo_list_object_addr), E_NOT_INITIALIZED);
        // gets the TodoList resource
        let todo_list = borrow_global_mut<TodoList>(todo_list_object_addr);
        // creates a new Todo
        let new_todo = Todo {
            content,
            completed: false
        };
        // adds the new todo into the todos table
        vector::push_back(&mut todo_list.todos, new_todo);
    }

    public entry fun complete_todo(account: &signer, todo_list_idx: u64, todo_id: u64) acquires TodoList {
        let todo_list_object_addr = object::create_object_address(&signer::address_of(account), to_bytes(&todo_list_idx));
        // assert signer has created a list
        assert!(exists<TodoList>(todo_list_object_addr), E_NOT_INITIALIZED);
        // gets the TodoList resource
        let todo_list = borrow_global_mut<TodoList>(todo_list_object_addr);
        // assert todo exists
        assert!(todo_id < vector::length(&todo_list.todos), ETODO_DOESNT_EXIST);
        // gets the todo matched the todo_id
        let todo_record = vector::borrow_mut(&mut todo_list.todos, todo_id);
        // assert todo is not completed
        assert!(todo_record.completed == false, ETODO_IS_COMPLETED);
        // update todo as completed
        todo_record.completed = true;
    }

    #[test_only]
    use std::string;
    #[test_only]
    use aptos_framework::account;

    #[test(admin = @0x100)]
    public entry fun test_flow(admin: signer) acquires TodoList, UserTodoListCounter {
        // creates an admin @todolist_addr account for test
        account::create_account_for_test(signer::address_of(&admin));
        // initialize contract with admin account
        create_todo_list(&admin);

        // creates a todo by the admin account
        create_todo(&admin, 0, string::utf8(b"New Todo"));
        let todo_list = borrow_global<TodoList>(signer::address_of(&admin));
        assert!(todo_list.owner == signer::address_of(&admin), 2);

        assert!(vector::length(&todo_list.todos) == 1, 3);
        let todo_record = vector::borrow(&todo_list.todos, vector::length(&todo_list.todos) - 1);
        assert!(todo_record.completed == false, 4);
        assert!(todo_record.content == string::utf8(b"New Todo"), 5);

        // updates todo as completed
        complete_todo(&admin, 0, 0);
        let todo_list = borrow_global<TodoList>(signer::address_of(&admin));
        let todo_record = vector::borrow(&todo_list.todos, 0);
        assert!(todo_record.completed == true, 6);
        assert!(todo_record.content == string::utf8(b"New Todo"), 7);
    }

    #[test(admin = @0x123)]
    #[expected_failure(abort_code = E_NOT_INITIALIZED)]
    public entry fun account_can_not_update_todo(admin: signer) acquires TodoList {
        // creates an admin @todolist_addr account for test
        account::create_account_for_test(signer::address_of(&admin));
        // account can not toggle todo as no list was created
        complete_todo(&admin, 0, 1);
    }
}