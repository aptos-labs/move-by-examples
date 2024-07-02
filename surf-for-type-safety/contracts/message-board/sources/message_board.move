module message_board_addr::message_board {
    use std::option::{Self, Option};
    use std::vector;
    use std::string::String;

    use aptos_std::math64;

    use aptos_framework::object::{Self, Object, ObjectCore};

    const DEFAULT_START_AFTER: u64 = 0;
    const DEFAULT_LIMIT: u64 = 10;

    struct Message has key, copy, drop {
        boolean_content: bool,
        string_content: String,
        number_content: u64,
        address_content: address,
        object_content: Object<ObjectCore>,
        vector_content: vector<String>,
        optional_boolean_content: Option<bool>,
        optional_string_content: Option<String>,
        optional_number_content: Option<u64>,
        optional_address_content: Option<address>,
        optional_object_content: Option<Object<ObjectCore>>,
        optional_vector_content: Option<vector<String>>,
    }

    struct MessageBoard has key {
        messages: vector<Object<Message>>,
    }

    // This function is only called once when the module is published for the first time.
    // init_module is optional, you can also have an entry function as the initializer.
    fun init_module(sender: &signer) {
        move_to(
            sender,
            MessageBoard {
                messages: vector::empty(),
            },
        )
    }

    // ======================== Write functions ========================

    public entry fun post_message(
        _sender: &signer,
        boolean_content: bool,
        string_content: String,
        number_content: u64,
        address_content: address,
        object_content: Object<ObjectCore>,
        vector_content: vector<String>,
        optional_boolean_content: Option<bool>,
        optional_string_content: Option<String>,
        optional_number_content: Option<u64>,
        optional_address_content: Option<address>,
        optional_object_content: Option<Object<ObjectCore>>,
        optional_vector_content: Option<vector<String>>,
    ) acquires MessageBoard {
        let message_obj_constructor_ref = &object::create_object(@message_board_addr);
        move_to(&object::generate_signer(message_obj_constructor_ref), Message {
            boolean_content,
            string_content,
            number_content,
            address_content,
            object_content,
            vector_content,
            optional_boolean_content,
            optional_string_content,
            optional_number_content,
            optional_address_content,
            optional_object_content,
            optional_vector_content,
        });
        let message_board = borrow_global_mut<MessageBoard>(@message_board_addr);
        vector::push_back(
            &mut message_board.messages,
            object::object_from_constructor_ref(message_obj_constructor_ref)
        );
    }

    // ======================== Read Functions ========================

    #[view]
    public fun get_messages(
        start_after: Option<u64>,
        limit: Option<u64>
    ): vector<Object<Message>> acquires MessageBoard {
        let messages = borrow_global<MessageBoard>(@message_board_addr).messages;
        let results = vector[];
        let start_idx = if (option::is_some(&start_after)) {
            *option::borrow(&start_after) + 1
        } else {
            DEFAULT_START_AFTER
        };
        let end_idx = math64::min(
            vector::length(&messages),
            start_idx + *option::borrow_with_default(&limit, &DEFAULT_LIMIT)
        );
        for (i in start_idx..end_idx) {
            let message_obj = *vector::borrow(&messages, i);
            vector::push_back(&mut results, message_obj);
        };
        results
    }

    #[view]
    public fun get_message_struct(
        message_obj: Object<Message>
    ): Message acquires Message {
        let message = borrow_global<Message>(object::object_address(&message_obj));
        *message
    }

    #[view]
    public fun get_message_content(message_obj: Object<Message>): (
        bool,
        String,
        u64,
        address,
        Object<ObjectCore>,
        vector<String>,
        Option<bool>,
        Option<String>,
        Option<u64>,
        Option<address>,
        Option<Object<ObjectCore>>,
        Option<vector<String>>,
    ) acquires Message {
        let message = borrow_global<Message>(object::object_address(&message_obj));
        (
            message.boolean_content,
            message.string_content,
            message.number_content,
            message.address_content,
            message.object_content,
            message.vector_content,
            message.optional_boolean_content,
            message.optional_string_content,
            message.optional_number_content,
            message.optional_address_content,
            message.optional_object_content,
            message.optional_vector_content,
        )
    }

    // ======================== Unit Tests ========================

    #[test_only]
    use std::string;
    #[test_only]
    use std::signer;

    #[test(sender = @message_board_addr)]
    fun test_end_to_end<>(sender: &signer) acquires MessageBoard, Message {
        let sende_addr = signer::address_of(sender);

        init_module(sender);

        let obj_constructor_ref = &object::create_object(sende_addr);
        let obj = object::object_from_constructor_ref<ObjectCore>(obj_constructor_ref);

        post_message(
            sender,
            true,
            string::utf8(b"hello world"),
            42,
            @0x1,
            obj,
            vector[string::utf8(b"hello")],
            option::some(true),
            option::some(string::utf8(b"hello")),
            option::some(42),
            option::some(@0x1),
            option::some(obj),
            option::some(vector[string::utf8(b"hello")]),
        );

        let messages = get_messages(option::none(), option::none());
        let message = *vector::borrow(&messages, 0);
        let message_struct = &get_message_struct(message);
        assert!(message_struct == &Message{
            boolean_content: true,
            string_content: string::utf8(b"hello world"),
            number_content: 42,
            address_content: @0x1,
            object_content: obj,
            vector_content: vector[string::utf8(b"hello")],
            optional_boolean_content: option::some(true),
            optional_string_content: option::some(string::utf8(b"hello")),
            optional_number_content: option::some(42),
            optional_address_content: option::some(@0x1),
            optional_object_content: option::some(obj),
            optional_vector_content: option::some(vector[string::utf8(b"hello")]),
        }, 1);

        let (
            boolean_content,
            string_content,
            number_content,
            address_content,
            object_content,
            vector_content,
            optional_boolean_content,
            optional_string_content,
            optional_number_content,
            optional_address_content,
            optional_object_content,
            optional_vector_content,
        ) = get_message_content(message);
        assert!(boolean_content == true, 2);
        assert!(string_content == string::utf8(b"hello world"), 3);
        assert!(number_content == 42, 4);
        assert!(address_content == @0x1, 5);
        assert!(object_content == obj, 6);
        assert!(vector_content == vector[string::utf8(b"hello")], 7);
        assert!(optional_boolean_content == option::some(true), 8);
        assert!(optional_string_content == option::some(string::utf8(b"hello")), 9);
        assert!(optional_number_content == option::some(42), 10);
        assert!(optional_address_content == option::some(@0x1), 11);
        assert!(optional_object_content == option::some(obj), 12);
        assert!(optional_vector_content == option::some(vector[string::utf8(b"hello")]), 13);
    }
}
