module simple_todo_list_addr::simple_todo_list {
    use std::signer;
    use std::vector;
    use std::string::String;

    /// Todo list does not exist
    const E_TODO_LIST_DOSE_NOT_EXIST: u64 = 1;
    /// Try to create another todo list, but each user can only have one todo list
    const E_EACH_USER_CAN_ONLY_HAVE_ONE_TODO_LIST: u64 = 2;
    /// Todo does not exist
    const E_TODO_DOSE_NOT_EXIST: u64 = 3;
    /// Todo is already completed
    const E_TODO_ALREADY_COMPLETED: u64 = 4;

    struct TodoList has key {
        owner: address,
        todos: vector<Todo>,
    }

    struct Todo has store, drop, copy {
        content: String,
        completed: bool,
    }

    // This function is only called once when the module is published for the first time.
    // init_module is optional, you can also have an entry function as the initializer.
    fun init_module(_module_publisher: &signer) {
        // nothing to do here
    }

    // ======================== Write functions ========================

    public entry fun create_todo_list(sender: &signer) {
        let sender_address = signer::address_of(sender);
        assert!(
            !exists<TodoList>(sender_address),
            E_EACH_USER_CAN_ONLY_HAVE_ONE_TODO_LIST
        );
        let todo_list = TodoList {
            owner: sender_address,
            todos: vector::empty(),
        };
        // store the TodoList resource directly under the sender
        move_to(sender, todo_list);
    }

    public entry fun create_todo(sender: &signer, content: String) acquires TodoList {
        let sender_address = signer::address_of(sender);
        assert_user_has_todo_list(sender_address);
        let todo_list = borrow_global_mut<TodoList>(sender_address);
        let new_todo = Todo {
            content,
            completed: false
        };
        vector::push_back(&mut todo_list.todos, new_todo);
    }

    public entry fun complete_todo(sender: &signer, todo_idx: u64) acquires TodoList {
        let sender_address = signer::address_of(sender);
        assert_user_has_todo_list(sender_address);
        let todo_list = borrow_global_mut<TodoList>(sender_address);
        assert_user_has_given_todo(todo_list, todo_idx);
        let todo_record = vector::borrow_mut(&mut todo_list.todos, todo_idx);
        assert!(todo_record.completed == false, E_TODO_ALREADY_COMPLETED);
        todo_record.completed = true;
    }

    // ======================== Read Functions ========================

    #[view]
    public fun has_todo_list(sender: address): bool {
        exists<TodoList>(sender)
    }

    #[view]
    public fun get_todo_list(sender: address): (address, u64) acquires TodoList {
        assert_user_has_todo_list(sender);
        let todo_list = borrow_global<TodoList>(sender);
        (todo_list.owner, vector::length(&todo_list.todos))
    }

    #[view]
    public fun get_todo(sender: address, todo_idx: u64): (String, bool) acquires TodoList {
        assert_user_has_todo_list(sender);
        let todo_list = borrow_global<TodoList>(sender);
        assert!(todo_idx < vector::length(&todo_list.todos), E_TODO_DOSE_NOT_EXIST);
        let todo_record = vector::borrow(&todo_list.todos, todo_idx);
        (todo_record.content, todo_record.completed)
    }

    // ======================== Helper Functions ========================

    fun assert_user_has_todo_list(user_addr: address) {
        assert!(
            exists<TodoList>(user_addr),
            E_TODO_LIST_DOSE_NOT_EXIST
        );
    }

    fun assert_user_has_given_todo(todo_list: &TodoList, todo_idx: u64) {
        assert!(
            todo_idx < vector::length(&todo_list.todos),
            E_TODO_DOSE_NOT_EXIST
        );
    }

    // ======================== Unit Tests ========================

    #[test_only]
    use std::string;
    #[test_only]
    use aptos_std::string_utils;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_std::debug;

    #[test(admin = @0x100)]
    public entry fun test_end_to_end(admin: signer) acquires TodoList {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        assert!(!has_todo_list(admin_addr), 1);
        create_todo_list(&admin);
        assert!(has_todo_list(admin_addr), 2);

        create_todo(&admin, string::utf8(b"New Todo"));
        let (todo_list_owner, todo_list_length) = get_todo_list(admin_addr);
        debug::print(&string_utils::format1(&b"todo_list_owner: {}", todo_list_owner));
        debug::print(&string_utils::format1(&b"todo_list_length: {}", todo_list_length));
        assert!(todo_list_owner == admin_addr, 3);
        assert!(todo_list_length == 1, 4);

        let (todo_content, todo_completed) = get_todo(admin_addr, 0);
        debug::print(&string_utils::format1(&b"todo_content: {}", todo_content));
        debug::print(&string_utils::format1(&b"todo_completed: {}", todo_completed));
        assert!(!todo_completed, 5);
        assert!(todo_content == string::utf8(b"New Todo"), 6);

        complete_todo(&admin, 0);
        let (_todo_content, todo_completed) = get_todo(admin_addr, 0);
        debug::print(&string_utils::format1(&b"todo_completed: {}", todo_completed));
        assert!(todo_completed, 7);
    }

    #[test(admin = @0x100)]
    #[expected_failure(abort_code = E_TODO_LIST_DOSE_NOT_EXIST, location = Self)]
    public entry fun test_todo_list_does_not_exist(admin: signer) acquires TodoList {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        // account can not create todo as no list was created
        create_todo(&admin, string::utf8(b"New Todo"));
    }

    #[test(admin = @0x100)]
    #[expected_failure(abort_code = E_EACH_USER_CAN_ONLY_HAVE_ONE_TODO_LIST, location = Self)]
    public entry fun test_each_user_can_only_have_one_todo_list(admin: signer) {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        create_todo_list(&admin);
        // can not create another todo list, since in this code we store TodoList as a resource under user
        // and under same user, we can only have one resource of the same type
        // see advanced todo list example for how to handle multiple todo lists under same user
        create_todo_list(&admin);
    }

    #[test(admin = @0x100)]
    #[expected_failure(abort_code = E_TODO_DOSE_NOT_EXIST, location = Self)]
    public entry fun test_todo_does_not_exist(admin: signer) acquires TodoList {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        create_todo_list(&admin);
        // can not complete todo that does not exist
        complete_todo(&admin, 1);
    }

    #[test(admin = @0x100)]
    #[expected_failure(abort_code = E_TODO_ALREADY_COMPLETED, location = Self)]
    public entry fun test_todo_already_completed(admin: signer) acquires TodoList {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        create_todo_list(&admin);
        create_todo(&admin, string::utf8(b"New Todo"));
        complete_todo(&admin, 0);
        // can not complete todo that is already completed
        complete_todo(&admin, 0);
    }
}
