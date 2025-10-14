#[test_only]
module vesting::vesting_tests {
    use aptos_framework::account;
    use aptos_framework::timestamp;
    use aptos_framework::primary_fungible_store;
    use aptos_framework::object::{Self, Object};
    use aptos_framework::fungible_asset::{Self, Metadata};

    use std::signer;
    use std::option;
    use std::string;

    use vesting::vesting;

    fun create_and_mint_dummy_token(
        creator: &signer, initial_amount: u64
    ): Object<Metadata> {
        let creator_addr = signer::address_of(creator);
        let token_obj_constructor_ref = &object::create_sticky_object(creator_addr);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            token_obj_constructor_ref,
            option::none(),
            string::utf8(b"Dummy Token"),
            string::utf8(b"DUMMY"),
            6,
            string::utf8(b"https://example.com"),
            string::utf8(b"https://example.com/dummy.png")
        );
        let mint_ref = &fungible_asset::generate_mint_ref(token_obj_constructor_ref);
        let minted_token = fungible_asset::mint(mint_ref, initial_amount);
        primary_fungible_store::deposit(creator_addr, minted_token);

        object::object_from_constructor_ref(token_obj_constructor_ref)
    }

    fun setup_test(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ): (address, address) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::fast_forward_seconds(100);

        let creator_addr = signer::address_of(creator);
        let recipient_addr = signer::address_of(recipient);
        account::create_account_for_test(creator_addr);
        account::create_account_for_test(recipient_addr);

        (creator_addr, recipient_addr)
    }

    fun setup_test_with_attacker(
        aptos_framework: &signer,
        creator: &signer,
        recipient: &signer,
        attacker: &signer
    ): (address, address, address) {
        let (creator_addr, recipient_addr) =
            setup_test(aptos_framework, creator, recipient);

        let attacker_addr = signer::address_of(attacker);
        account::create_account_for_test(attacker_addr);

        (creator_addr, recipient_addr, attacker_addr)
    }

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    fun test_create_vesting_success(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (creator_addr, recipient_addr) =
            setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        let start_timestamp = 200;
        let duration = 1000;
        let release_rate = 10;

        vesting::create_vesting(
            creator,
            start_timestamp,
            duration,
            release_rate,
            token,
            recipient_addr
        );

        let creator_balance = primary_fungible_store::balance(creator_addr, token);
        assert!(creator_balance == 0, 0); // 10000 - (10 * 1000) = 0
    }

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    fun test_claim_vested_tokens_full_duration(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        let vesting_obj =
            vesting::create_vesting(creator, 200, 1000, 10, token, recipient_addr);

        timestamp::fast_forward_seconds(1100); // Now at 1200, past end (1200)
        vesting::claim_vested(recipient, vesting_obj);

        let recipient_balance = primary_fungible_store::balance(recipient_addr, token);
        assert!(recipient_balance == 10000, 1); // 1000 * 10 = 10000
    }

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    fun test_claim_vested_tokens_partial(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        let vesting_obj =
            vesting::create_vesting(creator, 200, 1000, 10, token, recipient_addr);

        timestamp::fast_forward_seconds(600); // Now at 700, elapsed = 500
        vesting::claim_vested(recipient, vesting_obj);

        let recipient_balance = primary_fungible_store::balance(recipient_addr, token);
        assert!(recipient_balance == 5000, 2); // 500 * 10 = 5000

        timestamp::fast_forward_seconds(500); // Now at 1200
        vesting::claim_vested(recipient, vesting_obj);

        let final_balance = primary_fungible_store::balance(recipient_addr, token);
        assert!(final_balance == 10000, 3);
    }

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    #[expected_failure(abort_code = vesting::ENO_TOKENS_TO_CLAIM, location = vesting)]
    fun test_claim_before_vesting_starts(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        let vesting_obj =
            vesting::create_vesting(creator, 200, 1000, 10, token, recipient_addr);

        vesting::claim_vested(recipient, vesting_obj);
    }

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    #[
        expected_failure(
            abort_code = vesting::ETOTAL_VESTING_AMOUNT_OVERFLOW, location = vesting
        )
    ]
    fun test_create_vesting_overflow(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        vesting::create_vesting(
            creator,
            200,
            18446744073709551615,
            100,
            token,
            recipient_addr
        );
    }

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    #[expected_failure(abort_code = vesting::ENO_TOKENS_TO_CLAIM, location = vesting)]
    fun test_claim_zero_tokens(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        let vesting_obj =
            vesting::create_vesting(creator, 200, 1000, 10, token, recipient_addr);

        timestamp::fast_forward_seconds(300); // Now at 400, elapsed = 200
        vesting::claim_vested(recipient, vesting_obj);

        // Try to claim again immediately
        vesting::claim_vested(recipient, vesting_obj);
    }

    #[test(
        aptos_framework = @0x1, creator = @0x123, recipient = @0x456, attacker = @0x789
    )]
    #[expected_failure(
        abort_code = vesting::EONLY_RECIPIENT_CAN_CLAIM, location = vesting
    )]
    fun test_unauthorized_claim(
        aptos_framework: &signer,
        creator: &signer,
        recipient: &signer,
        attacker: &signer
    ) {
        let (_, recipient_addr, _) =
            setup_test_with_attacker(aptos_framework, creator, recipient, attacker);
        let token = create_and_mint_dummy_token(creator, 10000);

        let vesting_obj =
            vesting::create_vesting(creator, 200, 1000, 10, token, recipient_addr);

        timestamp::fast_forward_seconds(300);
        vesting::claim_vested(attacker, vesting_obj);
    }

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    #[
        expected_failure(
            abort_code = vesting::ESTART_TIMESTAMP_MUST_BE_IN_FUTURE, location = vesting
        )
    ]
    fun test_start_timestamp_in_past(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        vesting::create_vesting(creator, 50, 1000, 10, token, recipient_addr);
    }

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    #[
        expected_failure(
            abort_code = vesting::EDURATION_MUST_BE_GREATER_THAN_ZERO, location = vesting
        )
    ]
    fun test_zero_duration(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        vesting::create_vesting(creator, 200, 0, 10, token, recipient_addr);
    }

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    #[
        expected_failure(
            abort_code = vesting::ERELEASE_RATE_MUST_BE_GREATER_THAN_ZERO,
            location = vesting
        )
    ]
    fun test_zero_release_rate(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        vesting::create_vesting(creator, 200, 1000, 0, token, recipient_addr);
    }
}

