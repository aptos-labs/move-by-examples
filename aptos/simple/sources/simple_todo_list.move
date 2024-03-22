module simple_todo_list_addr::simple_todo_list {
    use std::signer;
    use std::vector;
    use std::string::String;
    
    // Errors
    const E_TODO_LIST_DOESNT_EXIST: u64 = 1;
    const E_TODO_LIST_ALREADY_EXISTS: u64 = 2;
    const E_TODO_DOESNT_EXIST: u64 = 3;
    const E_TODO_IS_COMPLETED: u64 = 4;

    struct TodoList has key {
        owner: address,
        todos: vector<Todo>,
    }

    struct Todo has store, drop, copy {
        content: String,
        completed: bool,
    }

    // This function is only called once when the module is published for the first time.
    fun init_module(_deployer: &signer) {
        // nothing to do here
    }

    public entry fun create_todo_list(account: &signer) {
        assert!(
            !exists<TodoList>(signer::address_of(account)),
            E_TODO_LIST_ALREADY_EXISTS
        );
        let todo_list = TodoList {
            owner: signer::address_of(account),
            todos: vector::empty(),
        };
        // move the TodoList resource under the signer account
        move_to(account, todo_list);
    }

    public entry fun create_todo(account: &signer, content: String) acquires TodoList {
        // gets the signer address
        let signer_address = signer::address_of(account);
        // assert signer has created a list
        assert!(exists<TodoList>(signer_address), E_TODO_LIST_DOESNT_EXIST);
        // gets the TodoList resource
        let todo_list = borrow_global_mut<TodoList>(signer_address);
        // creates a new Todo
        let new_todo = Todo {
            content,
            completed: false
        };
        // adds the new todo into the todos table
        vector::push_back(&mut todo_list.todos, new_todo);
    }

    public entry fun complete_todo(account: &signer, todo_id: u64) acquires TodoList {
        // gets the signer address
        let signer_address = signer::address_of(account);
        // assert signer has created a list
        assert!(exists<TodoList>(signer_address), E_TODO_LIST_DOESNT_EXIST);
        // gets the TodoList resource
        let todo_list = borrow_global_mut<TodoList>(signer_address);
        // assert todo exists
        assert!(todo_id < vector::length(&todo_list.todos), E_TODO_DOESNT_EXIST);
        // gets the todo matched the todo_id
        let todo_record = vector::borrow_mut(&mut todo_list.todos, todo_id);
        // assert todo is not completed
        assert!(todo_record.completed == false, E_TODO_IS_COMPLETED);
        // update todo as completed
        todo_record.completed = true;
    }

    #[test_only]
    use std::string;
    #[test_only]
    use aptos_framework::account;

    #[test(admin = @0x100)]
    public entry fun test_flow(admin: signer) acquires TodoList {
        // creates an admin @todolist_addr account for test
        account::create_account_for_test(signer::address_of(&admin));
        // initialize contract with admin account
        create_todo_list(&admin);

        // creates a todo by the admin account
        create_todo(&admin, string::utf8(b"New Todo"));
        let todo_list = borrow_global<TodoList>(signer::address_of(&admin));
        assert!(todo_list.owner == signer::address_of(&admin), 2);

        assert!(vector::length(&todo_list.todos) == 1, 3);
        let todo_record = vector::borrow(&todo_list.todos, vector::length(&todo_list.todos) - 1);
        assert!(todo_record.completed == false, 4);
        assert!(todo_record.content == string::utf8(b"New Todo"), 5);

        // updates todo as completed
        complete_todo(&admin, 0);
        let todo_list = borrow_global<TodoList>(signer::address_of(&admin));
        let todo_record = vector::borrow(&todo_list.todos, 0);
        assert!(todo_record.completed == true, 6);
        assert!(todo_record.content == string::utf8(b"New Todo"), 7);
    }

    #[test(admin = @0x123)]
    #[expected_failure(abort_code = E_TODO_LIST_DOESNT_EXIST)]
    public entry fun account_can_not_update_todo(admin: signer) acquires TodoList {
        // creates an admin @todolist_addr account for test
        account::create_account_for_test(signer::address_of(&admin));
        // account can not toggle todo as no list was created
        complete_todo(&admin, 1);
    }

    #[test(admin = @0x123)]
    #[expected_failure(abort_code = E_TODO_LIST_ALREADY_EXISTS, location = Self)]
    public entry fun cannot_create_2_todo_list(admin: signer) {
        // creates an admin @todolist_addr account for test
        account::create_account_for_test(signer::address_of(&admin));
        create_todo_list(&admin);
        // wll get resource already exists error
        create_todo_list(&admin);
    }
}