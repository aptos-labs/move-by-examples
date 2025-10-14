module vesting::vesting {
    use aptos_framework::event;
    use aptos_framework::object::{Self, ExtendRef, Object};
    use aptos_framework::fungible_asset::{Metadata};
    use aptos_framework::primary_fungible_store;
    use aptos_framework::timestamp;

    use std::signer;

    /// Start timestamp must be in the future
    const ESTART_TIMESTAMP_MUST_BE_IN_FUTURE: u64 = 1;
    /// Duration must be greater than zero
    const EDURATION_MUST_BE_GREATER_THAN_ZERO: u64 = 2;
    /// Release rate must be greater than zero
    const ERELEASE_RATE_MUST_BE_GREATER_THAN_ZERO: u64 = 3;
    /// Only the recipient can claim vested tokens
    const EONLY_RECIPIENT_CAN_CLAIM: u64 = 4;
    /// Total vesting amount would overflow
    const ETOTAL_VESTING_AMOUNT_OVERFLOW: u64 = 5;
    /// No tokens available to claim
    const ENO_TOKENS_TO_CLAIM: u64 = 6;

    #[event]
    struct CreateVestingEvent has drop, store {
        vesting_obj: address,
        creator: address,
        start_timestamp: u64,
        duration: u64,
        release_rate: u64,
        vesting_token: address,
        recipient: address
    }

    #[event]
    struct ClaimVestedEvent has drop, store {
        vesting_obj_address: address,
        claimer: address,
        amount_claimed: u64
    }

    struct Vesting has key {
        /// in unix timestamp in seconds
        start_timestamp: u64,
        /// in seconds
        duration: u64,
        /// in units of the asset
        release_rate: u64,
        /// the asset being vested
        vesting_token: Object<Metadata>,
        /// the recipient of the vested tokens
        recipient: address,
        /// total amount of tokens that have already been claimed
        already_claimed: u64,
        /// extend ref to generate the object signer
        extend_ref: ExtendRef
    }

    fun init_module(_deployer: &signer) {
        // module initialization logic if needed
    }

    public entry fun create_vesting_entry(
        creator: &signer,
        start_timestamp: u64,
        duration: u64,
        release_rate: u64,
        vesting_token: Object<Metadata>,
        recipient: address
    ) {
        create_vesting(
            creator,
            start_timestamp,
            duration,
            release_rate,
            vesting_token,
            recipient
        );
    }

    public fun create_vesting(
        creator: &signer,
        start_timestamp: u64,
        duration: u64,
        release_rate: u64,
        vesting_token: Object<Metadata>,
        recipient: address
    ): Object<Vesting> {
        let current_time = timestamp::now_seconds();
        assert!(start_timestamp > current_time, ESTART_TIMESTAMP_MUST_BE_IN_FUTURE);
        assert!(duration > 0, EDURATION_MUST_BE_GREATER_THAN_ZERO);
        assert!(release_rate > 0, ERELEASE_RATE_MUST_BE_GREATER_THAN_ZERO);

        // Check for overflow: release_rate * duration
        let total_amount_u128 = (release_rate as u128) * (duration as u128);
        assert!(
            total_amount_u128 <= (18446744073709551615u128),
            ETOTAL_VESTING_AMOUNT_OVERFLOW
        );
        let total_amount = (total_amount_u128 as u64);

        let creator_addr = signer::address_of(creator);
        let vesting_obj_constructor_ref = &object::create_object(creator_addr);
        let vesting_obj_signer = object::generate_signer(vesting_obj_constructor_ref);
        let vesting_obj_addr =
            object::address_from_constructor_ref(vesting_obj_constructor_ref);

        move_to(
            &vesting_obj_signer,
            Vesting {
                start_timestamp,
                duration,
                release_rate,
                vesting_token,
                recipient,
                already_claimed: 0,
                extend_ref: object::generate_extend_ref(vesting_obj_constructor_ref)
            }
        );

        primary_fungible_store::transfer(
            creator,
            vesting_token,
            vesting_obj_addr,
            total_amount
        );

        event::emit(
            CreateVestingEvent {
                vesting_obj: vesting_obj_addr,
                creator: creator_addr,
                start_timestamp,
                duration,
                release_rate,
                vesting_token: object::object_address(&vesting_token),
                recipient
            }
        );

        object::object_from_constructor_ref<Vesting>(vesting_obj_constructor_ref)
    }

    public entry fun claim_vested(
        claimer: &signer, vesting_obj: Object<Vesting>
    ) acquires Vesting {
        let claimer_addr = signer::address_of(claimer);
        let vesting_obj_addr = object::object_address(&vesting_obj);
        let vesting = borrow_global_mut<Vesting>(vesting_obj_addr);
        assert!(claimer_addr == vesting.recipient, EONLY_RECIPIENT_CAN_CLAIM);

        let current_time = timestamp::now_seconds();
        let elapsed_time =
            if (current_time < vesting.start_timestamp) { 0 }
            else if (current_time >= vesting.start_timestamp + vesting.duration) {
                vesting.duration
            } else {
                current_time - vesting.start_timestamp
            };

        // Check for overflow: elapsed_time * release_rate
        let total_vested_u128 = (elapsed_time as u128) * (vesting.release_rate as u128);
        assert!(
            total_vested_u128 <= (18446744073709551615 as u128),
            ETOTAL_VESTING_AMOUNT_OVERFLOW
        );
        let total_vested = (total_vested_u128 as u64);

        let claimable = total_vested - vesting.already_claimed;
        assert!(claimable > 0, ENO_TOKENS_TO_CLAIM);

        primary_fungible_store::transfer(
            &object::generate_signer_for_extending(&vesting.extend_ref),
            vesting.vesting_token,
            claimer_addr,
            claimable
        );

        vesting.already_claimed += claimable;

        event::emit(
            ClaimVestedEvent {
                vesting_obj_address: vesting_obj_addr,
                claimer: claimer_addr,
                amount_claimed: claimable
            }
        );
    }

    #[view]
    public fun get_vesting_detail(
        vesting_obj: Object<Vesting>
    ): (u64, u64, u64, address, address, u64) acquires Vesting {
        let vesting_obj_addr = object::object_address(&vesting_obj);
        let vesting = borrow_global<Vesting>(vesting_obj_addr);
        (
            vesting.start_timestamp,
            vesting.duration,
            vesting.release_rate,
            object::object_address(&vesting.vesting_token),
            vesting.recipient,
            vesting.already_claimed
        )
    }

    #[test_only]
    public fun init_for_test(vesting_signer: &signer) {
        init_module(vesting_signer);
    }
}

