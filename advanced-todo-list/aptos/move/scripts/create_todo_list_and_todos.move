script {
    use std::string;
    use std::signer;

    fun create_todo_list_and_todos(sender: &signer) {
        let sender_addr = signer::address_of(sender);
        advanced_todo_list_addr::advanced_todo_list::create_todo_list(sender);
        let latest_todo_list_idx = advanced_todo_list_addr::advanced_todo_list::get_todo_list_counter(sender_addr) - 1;

        let has_todo_list = advanced_todo_list_addr::advanced_todo_list::has_todo_list(
            sender_addr,
            latest_todo_list_idx
        );
        assert!(has_todo_list, 1);

        advanced_todo_list_addr::advanced_todo_list::create_todo(sender, latest_todo_list_idx, string::utf8(b"todo"));
        advanced_todo_list_addr::advanced_todo_list::create_todo(
            sender,
            latest_todo_list_idx,
            string::utf8(b"another todo")
        );

        // read todo list
        let (todo_list_owner, todo_list_length) = advanced_todo_list_addr::advanced_todo_list::get_todo_list(
            sender_addr,
            latest_todo_list_idx
        );
        // check todo list owner and length
        assert!(todo_list_owner == sender_addr, 2);
        assert!(todo_list_length == 2, 3);

        // read todo
        let (todo_content, todo_completed) = advanced_todo_list_addr::advanced_todo_list::get_todo(
            sender_addr,
            latest_todo_list_idx,
            0
        );
        // check todo 1 content and completed
        assert!(todo_content == string::utf8(b"todo"), 4);
        assert!(todo_completed == false, 5);

        // read another todo
        let (another_todo_content, another_todo_completed) = advanced_todo_list_addr::advanced_todo_list::get_todo(
            sender_addr,
            latest_todo_list_idx,
            1
        );
        // check todo 2 content and completed
        assert!(another_todo_content == string::utf8(b"another todo"), 6);
        assert!(another_todo_completed == false, 7);
    }
}
