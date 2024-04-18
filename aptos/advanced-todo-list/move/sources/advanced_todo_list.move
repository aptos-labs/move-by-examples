module advanced_todo_list_addr::advanced_todo_list {
    use std::bcs;
    use std::signer;
    use std::vector;
    use std::string::String;
    use aptos_std::string_utils;
    use aptos_framework::object;

    /// Todo list does not exist
    const E_TODO_LIST_DOSE_NOT_EXIST: u64 = 1;
    /// Todo does not exist
    const E_TODO_DOSE_NOT_EXIST: u64 = 2;
    /// Todo is already completed
    const E_TODO_ALREADY_COMPLETED: u64 = 3;

    struct UserTodoListCounter has key {
        counter: u64,
    }

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

    public entry fun create_todo_list(sender: &signer) acquires UserTodoListCounter {
        let sender_address = signer::address_of(sender);
        let counter = if (exists<UserTodoListCounter>(sender_address)) {
            let counter = borrow_global<UserTodoListCounter>(sender_address);
            counter.counter
        } else {
            let counter = UserTodoListCounter { counter: 0 };
            // store the UserTodoListCounter resource directly under the sender
            move_to(sender, counter);
            0
        };
        // create a new object to hold the todo list, use the contract_addr_counter as seed
        let obj_holds_todo_list = object::create_named_object(
            sender,
            construct_todo_list_object_seed(counter),
        );
        let obj_signer = object::generate_signer(&obj_holds_todo_list);
        let todo_list = TodoList {
            owner: sender_address,
            todos: vector::empty(),
        };
        // store the TodoList resource under the newly created object
        move_to(&obj_signer, todo_list);
        // increment the counter
        let counter = borrow_global_mut<UserTodoListCounter>(sender_address);
        counter.counter = counter.counter + 1;
    }

    public entry fun create_todo(sender: &signer, todo_list_idx: u64, content: String) acquires TodoList {
        let sender_address = signer::address_of(sender);
        let todo_list_obj_addr = object::create_object_address(
            &sender_address,
            construct_todo_list_object_seed(todo_list_idx)
        );
        assert_user_has_todo_list(todo_list_obj_addr);
        let todo_list = borrow_global_mut<TodoList>(todo_list_obj_addr);
        let new_todo = Todo {
            content,
            completed: false
        };
        vector::push_back(&mut todo_list.todos, new_todo);
    }

    public entry fun complete_todo(sender: &signer, todo_list_idx: u64, todo_idx: u64) acquires TodoList {
        let sender_address = signer::address_of(sender);
        let todo_list_obj_addr = object::create_object_address(
            &sender_address,
            construct_todo_list_object_seed(todo_list_idx)
        );
        assert_user_has_todo_list(todo_list_obj_addr);
        let todo_list = borrow_global_mut<TodoList>(todo_list_obj_addr);
        assert_user_has_given_todo(todo_list, todo_idx);
        let todo_record = vector::borrow_mut(&mut todo_list.todos, todo_idx);
        assert!(todo_record.completed == false, E_TODO_ALREADY_COMPLETED);
        todo_record.completed = true;
    }

    // ======================== Read Functions ========================

    // Get how many todo lists the sender has, return 0 if the sender has none.
    #[view]
    public fun get_todo_list_counter(sender: address): u64 acquires UserTodoListCounter {
        if (exists<UserTodoListCounter>(sender)) {
            let counter = borrow_global<UserTodoListCounter>(sender);
            counter.counter
        } else {
            0
        }
    }

    #[view]
    public fun get_todo_list_obj_addr(sender: address, todo_list_idx: u64): address {
        object::create_object_address(&sender, construct_todo_list_object_seed(todo_list_idx))
    }

    #[view]
    public fun has_todo_list(sender: address, todo_list_idx: u64): bool {
        let todo_list_obj_addr = get_todo_list_obj_addr(sender, todo_list_idx);
        exists<TodoList>(todo_list_obj_addr)
    }

    #[view]
    public fun get_todo_list(sender: address, todo_list_idx: u64): (address, u64) acquires TodoList {
        let todo_list_obj_addr = get_todo_list_obj_addr(sender, todo_list_idx);
        assert_user_has_todo_list(todo_list_obj_addr);
        let todo_list = borrow_global<TodoList>(todo_list_obj_addr);
        (todo_list.owner, vector::length(&todo_list.todos))
    }

    #[view]
    public fun get_todo_list_by_todo_list_obj_addr(todo_list_obj_addr: address): (address, u64) acquires TodoList {
        let todo_list = borrow_global<TodoList>(todo_list_obj_addr);
        (todo_list.owner, vector::length(&todo_list.todos))
    }

    #[view]
    public fun get_todo(sender: address, todo_list_idx: u64, todo_idx: u64): (String, bool) acquires TodoList {
        let todo_list_obj_addr = get_todo_list_obj_addr(sender, todo_list_idx);
        assert_user_has_todo_list(todo_list_obj_addr);
        let todo_list = borrow_global<TodoList>(todo_list_obj_addr);
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

    fun assert_user_has_given_todo(todo_list: &TodoList, todo_id: u64) {
        assert!(
            todo_id < vector::length(&todo_list.todos),
            E_TODO_DOSE_NOT_EXIST
        );
    }

    fun get_todo_list_obj(sender: address, todo_list_idx: u64): object::Object<TodoList> {
        let addr = get_todo_list_obj_addr(sender, todo_list_idx);
        object::address_to_object(addr)
    }

    fun construct_todo_list_object_seed(counter: u64): vector<u8> {
        // The seed must be unique per todo list creator
        //Wwe add contract address as part of the seed so seed from 2 todo list contract for same user would be different
        bcs::to_bytes(&string_utils::format2(&b"{}_{}", @advanced_todo_list_addr, counter))
    }

    // ======================== Unit Tests ========================

    #[test_only]
    use std::string;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_std::debug;

    #[test(admin = @0x100)]
    public entry fun test_end_to_end(admin: signer) acquires TodoList, UserTodoListCounter {
        let admin_addr = signer::address_of(&admin);
        let todo_list_idx = get_todo_list_counter(admin_addr);
        assert!(todo_list_idx == 0, 1);
        account::create_account_for_test(admin_addr);
        assert!(!has_todo_list(admin_addr, todo_list_idx), 2);
        create_todo_list(&admin);
        assert!(get_todo_list_counter(admin_addr) == 1, 3);
        assert!(has_todo_list(admin_addr, todo_list_idx), 4);

        create_todo(&admin, todo_list_idx, string::utf8(b"New Todo"));
        let (todo_list_owner, todo_list_length) = get_todo_list(admin_addr, todo_list_idx);
        debug::print(&string_utils::format1(&b"todo_list_owner: {}", todo_list_owner));
        debug::print(&string_utils::format1(&b"todo_list_length: {}", todo_list_length));
        assert!(todo_list_owner == admin_addr, 5);
        assert!(todo_list_length == 1, 6);

        let (todo_content, todo_completed) = get_todo(admin_addr, todo_list_idx, 0);
        debug::print(&string_utils::format1(&b"todo_content: {}", todo_content));
        debug::print(&string_utils::format1(&b"todo_completed: {}", todo_completed));
        assert!(!todo_completed, 7);
        assert!(todo_content == string::utf8(b"New Todo"), 8);

        complete_todo(&admin, todo_list_idx, 0);
        let (_todo_content, todo_completed) = get_todo(admin_addr, todo_list_idx, 0);
        debug::print(&string_utils::format1(&b"todo_completed: {}", todo_completed));
        assert!(todo_completed, 9);
    }

    #[test(admin = @0x100)]
    public entry fun test_end_to_end_2_todo_lists(admin: signer) acquires TodoList, UserTodoListCounter {
        let admin_addr = signer::address_of(&admin);
        create_todo_list(&admin);
        let todo_list_1_idx = get_todo_list_counter(admin_addr) - 1;
        create_todo_list(&admin);
        let todo_list_2_idx = get_todo_list_counter(admin_addr) - 1;

        create_todo(&admin, todo_list_1_idx, string::utf8(b"New Todo"));
        let (todo_list_owner, todo_list_length) = get_todo_list(admin_addr, todo_list_1_idx);
        assert!(todo_list_owner == admin_addr, 1);
        assert!(todo_list_length == 1, 2);

        let (todo_content, todo_completed) = get_todo(admin_addr, todo_list_1_idx, 0);
        assert!(!todo_completed, 3);
        assert!(todo_content == string::utf8(b"New Todo"), 4);

        complete_todo(&admin, todo_list_1_idx, 0);
        let (_todo_content, todo_completed) = get_todo(admin_addr, todo_list_1_idx, 0);
        assert!(todo_completed, 5);

        create_todo(&admin, todo_list_2_idx, string::utf8(b"New Todo"));
        let (todo_list_owner, todo_list_length) = get_todo_list(admin_addr, todo_list_2_idx);
        assert!(todo_list_owner == admin_addr, 6);
        assert!(todo_list_length == 1, 7);

        let (todo_content, todo_completed) = get_todo(admin_addr, todo_list_2_idx, 0);
        assert!(!todo_completed, 8);
        assert!(todo_content == string::utf8(b"New Todo"), 9);

        complete_todo(&admin, todo_list_2_idx, 0);
        let (_todo_content, todo_completed) = get_todo(admin_addr, todo_list_2_idx, 0);
        assert!(todo_completed, 10);
    }

    #[test(admin = @0x100)]
    #[expected_failure(abort_code = E_TODO_LIST_DOSE_NOT_EXIST, location = Self)]
    public entry fun test_todo_list_does_not_exist(admin: signer) acquires TodoList, UserTodoListCounter {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        let todo_list_idx = get_todo_list_counter(admin_addr);
        // account cannot create todo on a todo list (that does not exist
        create_todo(&admin, todo_list_idx, string::utf8(b"New Todo"));
    }

    #[test(admin = @0x100)]
    #[expected_failure(abort_code = E_TODO_DOSE_NOT_EXIST, location = Self)]
    public entry fun test_todo_does_not_exist(admin: signer) acquires TodoList, UserTodoListCounter {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        let todo_list_idx = get_todo_list_counter(admin_addr);
        create_todo_list(&admin);
        // can not complete todo that does not exist
        complete_todo(&admin, todo_list_idx, 1);
    }

    #[test(admin = @0x100)]
    #[expected_failure(abort_code = E_TODO_ALREADY_COMPLETED, location = Self)]
    public entry fun test_todo_already_completed(admin: signer) acquires TodoList, UserTodoListCounter {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        let todo_list_idx = get_todo_list_counter(admin_addr);
        create_todo_list(&admin);
        create_todo(&admin, todo_list_idx, string::utf8(b"New Todo"));
        complete_todo(&admin, todo_list_idx, 0);
        // can not complete todo that is already completed
        complete_todo(&admin, todo_list_idx, 0);
    }
}
