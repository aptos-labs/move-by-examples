script {
    use std::string;
    use std::signer;

    fun create_todo_list_if_not_exists_and_todos(sender: &signer) {
        let sender_addr = signer::address_of(sender);
        let has_todo_list = simple_todo_list_addr::simple_todo_list::has_todo_list(sender_addr);
        let next_todo_id = if (!has_todo_list) {
            simple_todo_list_addr::simple_todo_list::create_todo_list(sender);
            0
        } else {
            let (_todo_list_owner, todo_list_length) = simple_todo_list_addr::simple_todo_list::get_todo_list(
                sender_addr
            );
            todo_list_length
        };
        let previous_todo_list_len = next_todo_id;

        simple_todo_list_addr::simple_todo_list::create_todo(sender, string::utf8(b"todo"));
        simple_todo_list_addr::simple_todo_list::create_todo(sender, string::utf8(b"another todo"));

        // read todo list
        let (todo_list_owner, todo_list_length) = simple_todo_list_addr::simple_todo_list::get_todo_list(sender_addr);
        // check todo list owner and length
        assert!(todo_list_owner == sender_addr, 1);
        assert!(todo_list_length == previous_todo_list_len + 2, 2);

        // read todo
        let (todo_content, todo_completed) = simple_todo_list_addr::simple_todo_list::get_todo(
            sender_addr,
            next_todo_id
        );
        // check todo 1 content and completed
        assert!(todo_content == string::utf8(b"todo"), 3);
        assert!(todo_completed == false, 4);

        // read another todo
        let (another_todo_content, another_todo_completed) = simple_todo_list_addr::simple_todo_list::get_todo(
            sender_addr,
            next_todo_id + 1
        );
        // check todo 2 content and completed
        assert!(another_todo_content == string::utf8(b"another todo"), 5);
        assert!(another_todo_completed == false, 6);
    }
}
