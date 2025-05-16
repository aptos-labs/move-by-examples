#[test_only]
module taxed_fa_addr::taxed_fa_tests {
    use std::option;
    use std::signer;
    use std::string;
    use std::vector;

    use aptos_framework::object;
    use aptos_framework::primary_fungible_store;
    use aptos_framework::fungible_asset::Metadata;

    use taxed_fa_addr::taxed_fa;

    const MAX_SUPPLY: u64 = 1_000_000_000;

    #[
        test(
            deployer = @taxed_fa_addr,
            tfa_recipient = @tfa_recipient_addr,
            user1 = @0x11,
            user2 = @0x12
        )
    ]
    fun test_end_to_end(
        deployer: &signer,
        tfa_recipient: &signer,
        user1: &signer,
        user2: &signer
    ) {
        let user1_addr = signer::address_of(user1);
        let _user2_addr = signer::address_of(user2);

        taxed_fa::init_for_test(deployer);
        let tfa_metadata = object::address_to_object<Metadata>(taxed_fa::metadata_address());

        // at the bginning, the deployer should have the whole supply
        assert!(
            primary_fungible_store::balance(@tfa_recipient_addr, tfa_metadata)
                == MAX_SUPPLY,
            0
        );

        let registered_pools = taxed_fa::get_registered_pools();
        assert!(vector::length(&registered_pools) == 0, 1);

        // create a dummy object and a fungible store to simulate a lp pool
        let dummy_pool_obj_constructor_ref =
            &object::create_named_object(tfa_recipient, b"lp_obj");
        // create a dummy lp fa from the dummy lp pool object
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            dummy_pool_obj_constructor_ref,
            option::none(),
            string::utf8(b"TFA-APT-LP"),
            string::utf8(b"LP"),
            6,
            string::utf8(b"http://example.com/favicon.ico"),
            string::utf8(b"http://example.com")
        );
        let dummy_pool_obj_signer =
            &object::generate_signer(dummy_pool_obj_constructor_ref);
        let dummy_pool_addr =
            object::address_from_constructor_ref(dummy_pool_obj_constructor_ref);

        // deposit the whole supply to the pool
        primary_fungible_store::transfer(
            tfa_recipient,
            tfa_metadata,
            dummy_pool_addr,
            MAX_SUPPLY
        );

        assert!(
            primary_fungible_store::balance(@tfa_recipient_addr, tfa_metadata) == 0, 2
        );
        assert!(
            primary_fungible_store::balance(dummy_pool_addr, tfa_metadata) == MAX_SUPPLY,
            3
        );

        taxed_fa::register_pool(deployer, object::address_to_object(dummy_pool_addr));

        // simulate user 1 buy tfa from the pool, pool will send tfa to user1
        primary_fungible_store::transfer(
            dummy_pool_obj_signer,
            tfa_metadata,
            user1_addr,
            1_000_000
        );

        // pool should have 999_000_000 tfa after tax
        assert!(
            primary_fungible_store::balance(dummy_pool_addr, tfa_metadata)
                == 999_000_000,
            4
        );
        // user1 should have 900_000 tfa after tax
        assert!(primary_fungible_store::balance(user1_addr, tfa_metadata) == 900_000, 5);
        // deployer should have 100_000 tfa as tax income
        assert!(
            primary_fungible_store::balance(@tfa_recipient_addr, tfa_metadata)
                == 100_000,
            6
        );

        // simulate user 1 sell tfa to the pool, user1 will send tfa to pool
        primary_fungible_store::transfer(user1, tfa_metadata, dummy_pool_addr, 100_000);

        // pool should have 999_100_000 tfa after tax
        assert!(
            primary_fungible_store::balance(dummy_pool_addr, tfa_metadata)
                == 999_090_000,
            7
        );
        // user1 should have 800_000 tfa after tax
        assert!(primary_fungible_store::balance(user1_addr, tfa_metadata) == 800_000, 8);
        // deployer should have 110_000 tfa as tax income
        assert!(
            primary_fungible_store::balance(@tfa_recipient_addr, tfa_metadata)
                == 110_000,
            9
        );
    }
}
