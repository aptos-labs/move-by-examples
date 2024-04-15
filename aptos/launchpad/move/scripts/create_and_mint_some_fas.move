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
        let fa_obj_addr_1 = *vector::borrow(&registry, vector::length(&registry) - 1);
        assert!(launchpad::getTotalSupply(fa_obj_addr_1) == 0, 1);

        launchpad::mint_fa(sender, fa_obj_addr_1, 2);
        assert!(launchpad::getTotalSupply(fa_obj_addr_1) == 2, 2);
        assert!(launchpad::getBalance(fa_obj_addr_1, sender_addr) == 2, 3);

        // create second FA

        launchpad::create_fa(
            sender,
            option::some(100),
            string::utf8(b"FA2"),
            string::utf8(b"FA2"),
            2,
            string::utf8(b"icon_url"),
            string::utf8(b"project_url")
        );
        let registry = launchpad::get_registry();
        let fa_obj_addr_2 = *vector::borrow(&registry, vector::length(&registry) - 1);
        assert!(launchpad::getTotalSupply(fa_obj_addr_2) == 0, 4);

        launchpad::mint_fa(sender, fa_obj_addr_2, 3);
        assert!(launchpad::getTotalSupply(fa_obj_addr_2) == 3, 5);
        assert!(launchpad::getBalance(fa_obj_addr_2, sender_addr) == 3, 6);
    }
}
