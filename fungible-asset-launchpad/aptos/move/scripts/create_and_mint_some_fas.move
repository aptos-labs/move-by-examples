script {
    use std::option;
    use std::signer;
    use std::string;
    use std::vector;
    use launchpad_addr::launchpad;

    fun create_and_mint_some_fas(sender: &signer) {
        let sender_addr = signer::address_of(sender);

        // create first FA

        launchpad::create_fa(
            sender,
            option::some(100),
            string::utf8(b"FA1"),
            string::utf8(b"FA1"),
            2,
            string::utf8(b"icon_url"),
            string::utf8(b"project_url")
        );
        let registry = launchpad::get_registry();
        let fa_1 = *vector::borrow(&registry, vector::length(&registry) - 1);
        assert!(launchpad::get_current_supply(fa_1) == 0, 1);

        launchpad::mint_fa(sender, fa_1, 2);
        assert!(launchpad::get_current_supply(fa_1) == 200, 2);
        assert!(launchpad::get_balance(fa_1, sender_addr) == 200, 3);

        // create second FA

        launchpad::create_fa(
            sender,
            option::some(100),
            string::utf8(b"FA2"),
            string::utf8(b"FA2"),
            3,
            string::utf8(b"icon_url"),
            string::utf8(b"project_url")
        );
        let registry = launchpad::get_registry();
        let fa_2 = *vector::borrow(&registry, vector::length(&registry) - 1);
        assert!(launchpad::get_current_supply(fa_2) == 0, 4);

        launchpad::mint_fa(sender, fa_2, 3);
        assert!(launchpad::get_current_supply(fa_2) == 3000, 5);
        assert!(launchpad::get_balance(fa_2, sender_addr) == 3000, 6);
    }
}
