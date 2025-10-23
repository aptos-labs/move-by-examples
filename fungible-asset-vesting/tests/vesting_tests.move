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
        vesting::init_for_test(creator);

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
        let total_amount = 10000;

        vesting::create_vesting(
            creator,
            start_timestamp,
            duration,
            total_amount,
            token,
            recipient_addr,
            @0x0, // not cancellable
            0, // no cliff
            0 // 0% cliff percentage
        );

        let creator_balance = primary_fungible_store::balance(creator_addr, token);
        assert!(creator_balance == 0, 0); // 10000 - (10 * 1000) = 0

        let vestings = vesting::get_all_vestings();
        assert!(vestings.length() == 1, 1);
    }

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    fun test_claim_vested_tokens_full_duration(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        let vesting_obj =
            vesting::create_vesting(
                creator,
                200,
                1000,
                10000,
                token,
                recipient_addr,
                @0x0,
                0,
                0
            );

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
            vesting::create_vesting(
                creator,
                200,
                1000,
                10000,
                token,
                recipient_addr,
                @0x0,
                0,
                0
            );

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
            vesting::create_vesting(
                creator,
                200,
                1000,
                10000,
                token,
                recipient_addr,
                @0x0,
                0,
                0
            );

        vesting::claim_vested(recipient, vesting_obj);
    }

    // Note: Overflow test removed since we now use total_amount directly
    // instead of release_rate * duration

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    #[expected_failure(abort_code = vesting::ENO_TOKENS_TO_CLAIM, location = vesting)]
    fun test_claim_zero_tokens(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        let vesting_obj =
            vesting::create_vesting(
                creator,
                200,
                1000,
                10000,
                token,
                recipient_addr,
                @0x0,
                0,
                0
            );

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
            vesting::create_vesting(
                creator,
                200,
                1000,
                10000,
                token,
                recipient_addr,
                @0x0,
                0,
                0
            );

        timestamp::fast_forward_seconds(300);
        vesting::claim_vested(attacker, vesting_obj);
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

        vesting::create_vesting(
            creator,
            200,
            0,
            10000,
            token,
            recipient_addr,
            @0x0,
            0,
            0
        );
    }

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    #[
        expected_failure(
            abort_code = vesting::ETOTAL_AMOUNT_MUST_BE_GREATER_THAN_ZERO,
            location = vesting
        )
    ]
    fun test_zero_total_amount(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        vesting::create_vesting(
            creator,
            200,
            1000,
            0,
            token,
            recipient_addr,
            @0x0,
            0,
            0
        );
    }

    // ===== New Tests for Cliff and Cancellation =====

    #[test(aptos_framework = @0x1, creator = @0x123, recipient = @0x456)]
    fun test_vesting_with_cliff_25_percent(
        aptos_framework: &signer, creator: &signer, recipient: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let token = create_and_mint_dummy_token(creator, 10000);

        // Total: 10000, cliff at 100s releases 25% = 2500, then linear vest remaining 7500 over 900s
        let vesting_obj =
            vesting::create_vesting(
                creator,
                200, // start
                1000, // duration
                10000, // total_amount
                token,
                recipient_addr,
                @0x0, // not cancellable
                100, // cliff after 100s
                2500 // 25% in bips
            );

        // At cliff: 25% unlocked
        timestamp::fast_forward_seconds(200); // Now at 300, exactly at cliff (200 + 100)
        vesting::claim_vested(recipient, vesting_obj);
        let balance = primary_fungible_store::balance(recipient_addr, token);
        assert!(balance == 2500, 100); // 25% of 10000

        // Midway after cliff: cliff + half of remaining
        timestamp::fast_forward_seconds(450); // Now at 750, elapsed = 550 (450 after cliff)
        // Remaining: 7500, remaining duration: 900s, elapsed after cliff: 450s
        // Additional unlocked: 7500 * 450 / 900 = 3750
        vesting::claim_vested(recipient, vesting_obj);
        let balance2 = primary_fungible_store::balance(recipient_addr, token);
        assert!(balance2 == 6250, 101); // 2500 + 3750

        // At end of vesting
        timestamp::fast_forward_seconds(450); // Now at 1200
        vesting::claim_vested(recipient, vesting_obj);
        let final_balance = primary_fungible_store::balance(recipient_addr, token);
        assert!(final_balance == 10000, 102);
    }

    #[test(
        aptos_framework = @0x1, creator = @0x123, recipient = @0x456, canceller = @0xabc
    )]
    fun test_cancel_vesting_before_start(
        aptos_framework: &signer,
        creator: &signer,
        recipient: &signer,
        canceller: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let canceller_addr = signer::address_of(canceller);
        account::create_account_for_test(canceller_addr);
        let token = create_and_mint_dummy_token(creator, 10000);

        let vesting_obj =
            vesting::create_vesting(
                creator,
                200,
                1000,
                10000,
                token,
                recipient_addr,
                canceller_addr, // cancellable by this address
                0,
                0
            );

        // Cancel before vesting starts
        vesting::cancel_vesting(canceller, vesting_obj);

        // All tokens should go to canceller since nothing is unlocked
        let canceller_balance = primary_fungible_store::balance(canceller_addr, token);
        let recipient_balance = primary_fungible_store::balance(recipient_addr, token);
        assert!(canceller_balance == 10000, 200);
        assert!(recipient_balance == 0, 201);
    }

    #[test(
        aptos_framework = @0x1, creator = @0x123, recipient = @0x456, canceller = @0xabc
    )]
    fun test_cancel_vesting_midway(
        aptos_framework: &signer,
        creator: &signer,
        recipient: &signer,
        canceller: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let canceller_addr = signer::address_of(canceller);
        account::create_account_for_test(canceller_addr);
        let token = create_and_mint_dummy_token(creator, 10000);

        let vesting_obj =
            vesting::create_vesting(
                creator,
                200,
                1000,
                10000,
                token,
                recipient_addr,
                canceller_addr,
                0,
                0
            );

        // Fast forward to midway through vesting
        timestamp::fast_forward_seconds(700); // Now at 800, elapsed = 600, so 6000 unlocked
        vesting::cancel_vesting(canceller, vesting_obj);

        let canceller_balance = primary_fungible_store::balance(canceller_addr, token);
        let recipient_balance = primary_fungible_store::balance(recipient_addr, token);
        assert!(recipient_balance == 6000, 300); // 600s * 10 rate
        assert!(canceller_balance == 4000, 301); // remaining locked
    }

    #[test(
        aptos_framework = @0x1, creator = @0x123, recipient = @0x456, canceller = @0xabc
    )]
    fun test_cancel_vesting_after_completion(
        aptos_framework: &signer,
        creator: &signer,
        recipient: &signer,
        canceller: &signer
    ) {
        let (_, recipient_addr) = setup_test(aptos_framework, creator, recipient);
        let canceller_addr = signer::address_of(canceller);
        account::create_account_for_test(canceller_addr);
        let token = create_and_mint_dummy_token(creator, 10000);

        let vesting_obj =
            vesting::create_vesting(
                creator,
                200,
                1000,
                10000,
                token,
                recipient_addr,
                canceller_addr,
                0,
                0
            );

        // Fast forward past vesting end
        timestamp::fast_forward_seconds(1200); // Now at 1300, all unlocked
        vesting::cancel_vesting(canceller, vesting_obj);

        let canceller_balance = primary_fungible_store::balance(canceller_addr, token);
        let recipient_balance = primary_fungible_store::balance(recipient_addr, token);
        assert!(recipient_balance == 10000, 400); // all unlocked
        assert!(canceller_balance == 0, 401); // nothing left
    }

    #[test(
        aptos_framework = @0x1, creator = @0x123, recipient = @0x456, attacker = @0x789
    )]
    #[
        expected_failure(
            abort_code = vesting::EONLY_CANCELLABLE_BY_CAN_CANCEL, location = vesting
        )
    ]
    fun test_unauthorized_cancel(
        aptos_framework: &signer,
        creator: &signer,
        recipient: &signer,
        attacker: &signer
    ) {
        let (_, recipient_addr, _) =
            setup_test_with_attacker(aptos_framework, creator, recipient, attacker);
        let token = create_and_mint_dummy_token(creator, 10000);

        let vesting_obj =
            vesting::create_vesting(
                creator,
                200,
                1000,
                10000,
                token,
                recipient_addr,
                @0xabc, // only this address can cancel
                0,
                0
            );

        vesting::cancel_vesting(attacker, vesting_obj);
    }
}

