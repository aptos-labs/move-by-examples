script {
    use std::signer;

    fun complete_all_todos(sender: &signer) {
        let sender_addr = signer::address_of(sender);

        // read todo list
        let (_todo_list_owner, todo_list_length) = simple_todo_list_addr::simple_todo_list::get_todo_list(sender_addr);

        // complete all todos
        let () = for (i in 0..todo_list_length) {
            let (_todo_content, todo_completed) = simple_todo_list_addr::simple_todo_list::get_todo(sender_addr, i);
            if (todo_completed) {
                continue
            };
            simple_todo_list_addr::simple_todo_list::complete_todo(sender, i);
        };

        // check all todos are completed
        let () = for (i in 0..todo_list_length) {
            let (_todo_content, todo_completed) = simple_todo_list_addr::simple_todo_list::get_todo(sender_addr, i);
            assert!(todo_completed, i);
        };
    }
}
