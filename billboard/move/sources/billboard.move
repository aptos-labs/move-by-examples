module billboard_address::billboard {
    use std::error;
    use std::signer;
    use std::string::{String};
    use aptos_framework::event;
    use aptos_framework::timestamp;

    const ENOT_OWNER: u64 = 1;

    const MAX_MESSAGES: u64 = 5;

    struct Billboard has key {
        messages: vector<Message>,
        oldest_index: u64
    }

    struct Message has store, copy, drop {
        sender: address,
        message: String,
        added_at: u64
    }

    #[event]
    struct AddedMessage has drop, store {
        sender: address,
        message: String,
        added_at: u64
    }

    fun init_module(owner: &signer) {
        move_to(owner, Billboard { messages: vector[], oldest_index: 0 })
    }

    public entry fun add_message(sender: &signer, message: String) acquires Billboard {
        let message = Message {
            sender: signer::address_of(sender),
            message,
            added_at: timestamp::now_seconds()
        };

        event::emit(AddedMessage {
            sender: message.sender,
            message: message.message,
            added_at: message.added_at
        });

        let billboard = &mut Billboard[@billboard_address];

        if (billboard.messages.length() < MAX_MESSAGES) {
            billboard.messages.push_back(message);
            return
        };

        *billboard.messages.borrow_mut(billboard.oldest_index) = message;
        billboard.oldest_index = (billboard.oldest_index + 1) % MAX_MESSAGES;
    }

    public entry fun clear(owner: &signer) acquires Billboard {
        only_owner(owner);

        let billboard = &mut Billboard[@billboard_address];

        billboard.messages = vector[];
        billboard.oldest_index = 0;
    }

    inline fun only_owner(owner: &signer) {
        assert!(signer::address_of(owner) == @billboard_address, error::permission_denied(ENOT_OWNER));
    }

    #[view]
    public fun get_messages(): vector<Message> acquires Billboard {
        let billboard = &Billboard[@billboard_address];

        let messages = vector[];
        billboard.messages.for_each(|m| messages.push_back(m));

        messages.rotate(billboard.oldest_index);

        messages
    }

    #[test(aptos_framework = @std, owner = @billboard_address, alice = @0x1234, bob = @0xb0b)]
    fun test_billboard_happy_path(
        aptos_framework: &signer,
        owner: &signer,
        alice: &signer,
        bob: &signer
    ) acquires Billboard {
        use std::string;

        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::update_global_time_for_test_secs(1000);

        init_module(owner);

        let msgs = get_messages();

        assert!(msgs.length() == 0, 1);

        let alice_message = string::utf8(b"alice's message");
        let bob_message = string::utf8(b"bob's message");

        add_message(alice, alice_message);
        add_message(bob, bob_message);

        msgs = get_messages();

        assert!(msgs.length() == 2, 1);

        assert!(msgs.borrow(0).message == alice_message, 1);
        assert!(msgs.borrow(0).sender == signer::address_of(alice), 1);

        assert!(msgs.borrow(1).message == bob_message, 1);
        assert!(msgs.borrow(1).sender == signer::address_of(bob), 1);

        add_message(alice, alice_message);
        add_message(alice, alice_message);
        add_message(alice, alice_message);
        add_message(alice, alice_message);

        msgs = get_messages();

        assert!(msgs.length() == 5, 1);

        assert!(msgs.borrow(0).message == bob_message, 1);
        assert!(msgs.borrow(0).sender == signer::address_of(bob), 1);

        msgs = get_messages();

        assert!(msgs.length() == 5, 1);

        assert!(msgs.borrow(0).message == bob_message, 1);
        assert!(msgs.borrow(0).sender == signer::address_of(bob), 1);

        clear(owner);

        msgs = get_messages();

        assert!(msgs.length() == 0, 1);
    }
}
