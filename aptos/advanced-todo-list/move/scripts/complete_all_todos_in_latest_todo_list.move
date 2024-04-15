script {
    use std::signer;

    fun complete_all_todos_in_latest_todo_list(sender: &signer) {
        let sender_addr = signer::address_of(sender);
        let latest_todo_list_idx = advanced_todo_list_addr::advanced_todo_list::get_todo_list_counter(sender_addr) - 1;

        // read todo list
        let (_todo_list_owner, todo_list_length) = advanced_todo_list_addr::advanced_todo_list::get_todo_list(
            sender_addr,
            latest_todo_list_idx
        );

        // complete all todos
        let () = for (i in 0..todo_list_length) {
            let (_todo_content, todo_completed) = advanced_todo_list_addr::advanced_todo_list::get_todo(
                sender_addr,
                latest_todo_list_idx,
                i
            );
            if (todo_completed) {
                continue
            };
            advanced_todo_list_addr::advanced_todo_list::complete_todo(sender, latest_todo_list_idx, i);
        };

        // check all todos are completed
        let () = for (i in 0..todo_list_length) {
            let (_todo_content, todo_completed) = advanced_todo_list_addr::advanced_todo_list::get_todo(
                sender_addr,
                latest_todo_list_idx,
                i
            );
            assert!(todo_completed, i);
        };
    }
}
