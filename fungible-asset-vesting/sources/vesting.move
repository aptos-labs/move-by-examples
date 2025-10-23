module vesting::vesting {
    use aptos_framework::event;
    use aptos_framework::object::{Self, ExtendRef, Object};
    use aptos_framework::fungible_asset::{Metadata};
    use aptos_framework::primary_fungible_store;
    use aptos_framework::timestamp;

    use std::signer;

    /// Duration must be greater than zero
    const EDURATION_MUST_BE_GREATER_THAN_ZERO: u64 = 1;
    /// Cliff duration must be less than or equal to duration
    const ECLIFF_GREATER_THAN_DURATION: u64 = 2;
    /// Total amount must be greater than zero
    const ETOTAL_AMOUNT_MUST_BE_GREATER_THAN_ZERO: u64 = 3;
    /// Only the recipient can claim vested tokens
    const EONLY_RECIPIENT_CAN_CLAIM: u64 = 4;
    /// Total vesting amount would overflow
    const ETOTAL_VESTING_AMOUNT_OVERFLOW: u64 = 5;
    /// No tokens available to claim
    const ENO_TOKENS_TO_CLAIM: u64 = 6;
    /// Only the cancellable_by address can cancel the vesting
    const EONLY_CANCELLABLE_BY_CAN_CANCEL: u64 = 7;
    /// Cliff percentage must be between 0 and 10000 (0-100%)
    const ECLIFF_PERCENTAGE_INVALID: u64 = 8;
    /// Vesting has already been cancelled
    const EVESTING_ALREADY_CANCELLED: u64 = 9;

    /// Basis points precision (10000 = 100%)
    const BIPS_PRECISION: u64 = 10000;

    #[event]
    struct CreateVestingEvent has drop, store {
        vesting_obj: address,
        creator: address,
        start_timestamp: u64,
        duration: u64,
        total_amount: u64,
        vesting_token: address,
        recipient: address,
        cancellable_by: address,
        cliff_duration: u64,
        cliff_percentage_bips: u64
    }

    #[event]
    struct ClaimVestedEvent has drop, store {
        vesting_obj_address: address,
        claimer: address,
        amount_claimed: u64
    }

    #[event]
    struct CancelVestingEvent has drop, store {
        vesting_obj_address: address,
        canceller: address,
        amount_to_recipient: u64,
        amount_to_canceller: u64
    }

    struct Vestings has key {
        vestings: vector<Object<Vesting>>
    }

    struct Vesting has key {
        /// in unix timestamp in seconds
        start_timestamp: u64,
        /// total duration in seconds
        duration: u64,
        /// total amount of tokens to vest
        total_amount: u64,
        /// the asset being vested
        vesting_token: Object<Metadata>,
        /// the recipient of the vested tokens
        recipient: address,
        /// total amount of tokens that have already been claimed
        already_claimed: u64,
        /// address that can cancel the vesting (0x0 means not cancellable)
        cancellable_by: address,
        /// cliff duration in seconds (delay until first release, 0 for no cliff)
        cliff_duration: u64,
        /// percentage of total amount unlocked at cliff in basis points (0-10000, 0 for no cliff)
        cliff_percentage_bips: u64,
        /// extend ref to generate the object signer
        extend_ref: ExtendRef
    }

    fun init_module(deployer: &signer) {
        move_to(deployer, Vestings { vestings: vector[] })
    }

    public entry fun create_vesting_entry(
        creator: &signer,
        start_timestamp: u64,
        duration: u64,
        total_amount: u64,
        vesting_token: Object<Metadata>,
        recipient: address,
        cancellable_by: address,
        cliff_duration: u64,
        cliff_percentage_bips: u64
    ) acquires Vestings {
        create_vesting(
            creator,
            start_timestamp,
            duration,
            total_amount,
            vesting_token,
            recipient,
            cancellable_by,
            cliff_duration,
            cliff_percentage_bips
        );
    }

    /// Creates a new vesting schedule
    ///
    /// # Parameters
    /// * `creator` - The account creating and funding the vesting
    /// * `start_timestamp` - Unix timestamp when vesting begins (must be in future)
    /// * `duration` - Total vesting duration in seconds
    /// * `total_amount` - Total amount of tokens to vest
    /// * `vesting_token` - The fungible asset being vested
    /// * `recipient` - Address that can claim vested tokens
    /// * `cancellable_by` - Address authorized to cancel (use @0x0 for non-cancellable)
    /// * `cliff_duration` - Seconds until cliff unlock (0 for no cliff/pure linear vesting)
    /// * `cliff_percentage_bips` - Percentage unlocked at cliff in basis points, 0-10000 (0 for no cliff/pure linear vesting)
    ///
    /// # Examples
    /// Linear vesting 10,000 tokens over 365 days:
    ///   total_amount = 10000, duration = 31536000, cliff_duration = 0, cliff_percentage_bips = 0
    ///
    /// Cliff vesting: 25% after 30 days, then linear vest remaining 75% over remaining 335 days:
    ///   total_amount = 10000, duration = 31536000, cliff_duration = 2592000 (30 days), cliff_percentage_bips = 2500 (25%)
    public fun create_vesting(
        creator: &signer,
        start_timestamp: u64,
        duration: u64,
        total_amount: u64,
        vesting_token: Object<Metadata>,
        recipient: address,
        cancellable_by: address,
        cliff_duration: u64,
        cliff_percentage_bips: u64
    ): Object<Vesting> acquires Vestings {
        assert!(duration > 0, EDURATION_MUST_BE_GREATER_THAN_ZERO);
        assert!(cliff_duration <= duration, ECLIFF_GREATER_THAN_DURATION);
        assert!(total_amount > 0, ETOTAL_AMOUNT_MUST_BE_GREATER_THAN_ZERO);
        assert!(
            cliff_percentage_bips <= BIPS_PRECISION,
            ECLIFF_PERCENTAGE_INVALID
        );
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
                total_amount,
                vesting_token,
                recipient,
                already_claimed: 0,
                cancellable_by,
                cliff_duration,
                cliff_percentage_bips,
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
                total_amount,
                vesting_token: object::object_address(&vesting_token),
                recipient,
                cancellable_by,
                cliff_duration,
                cliff_percentage_bips
            }
        );
        let vesting_obj =
            object::object_from_constructor_ref<Vesting>(vesting_obj_constructor_ref);
        let vestings = borrow_global_mut<Vestings>(@vesting);
        vestings.vestings.push_back(vesting_obj);
        vesting_obj
    }

    public entry fun claim_vested(
        claimer: &signer, vesting_obj: Object<Vesting>
    ) acquires Vesting {
        let claimer_addr = signer::address_of(claimer);
        let vesting_obj_addr = object::object_address(&vesting_obj);
        let vesting = borrow_global_mut<Vesting>(vesting_obj_addr);
        assert!(claimer_addr == vesting.recipient, EONLY_RECIPIENT_CAN_CLAIM);
        let current_time = timestamp::now_seconds();
        let total_vested =
            calculate_unlocked(
                vesting.start_timestamp,
                current_time,
                vesting.total_amount,
                vesting.duration,
                vesting.cliff_duration,
                vesting.cliff_percentage_bips
            );
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

    /// Calculates how many tokens are unlocked for a vesting schedule at a given timestamp
    ///
    /// Supports two modes:
    /// 1. Linear vesting (no cliff): Tokens vest continuously from start to end
    /// 2. Cliff + linear: X% unlocks at cliff, then remaining tokens vest linearly until end
    fun calculate_unlocked(
        commenced_timestamp: u64,
        current_timestamp: u64,
        amount: u64,
        duration: u64,
        cliff_duration: u64,
        cliff_percentage_bips: u64
    ): u64 {
        // Nothing unlocked before commencement
        if (current_timestamp < commenced_timestamp) {
            return 0
        };
        let seconds_elapsed = current_timestamp - commenced_timestamp;
        // All tokens unlocked if vesting fully complete
        if (seconds_elapsed >= duration) {
            return amount
        };
        // If no cliff, simple linear vesting
        if (cliff_duration == 0 && cliff_percentage_bips == 0) {
            // Linear vesting: unlocked = (amount * elapsed) / duration
            return ((amount as u128) * (seconds_elapsed as u128) / (duration as u128) as u64)
        };
        // Before cliff: nothing unlocked
        if (seconds_elapsed < cliff_duration) {
            return 0
        };
        // At or after cliff: cliff amount + linear vesting of remainder
        let cliff_amount =
            ((amount as u128) * (cliff_percentage_bips as u128)
                / (BIPS_PRECISION as u128) as u64);
        // If we're exactly at the cliff, return just the cliff amount
        if (seconds_elapsed == cliff_duration) {
            return cliff_amount
        };
        // After cliff: linearly vest the remaining amount over remaining duration
        let remaining_amount = amount - cliff_amount;
        let remaining_duration = duration - cliff_duration;
        let elapsed_after_cliff = seconds_elapsed - cliff_duration;
        let additional_unlocked =
            ((remaining_amount as u128) * (elapsed_after_cliff as u128)
                / (remaining_duration as u128) as u64);
        cliff_amount + additional_unlocked
    }

    /// Cancels a vesting schedule
    ///
    /// Transfers unlocked tokens to the recipient and remaining locked tokens to the canceller.
    /// Useful for correcting mistakes before vesting starts or force-claiming after completion.
    ///
    /// # Parameters
    /// * `canceller` - Must be the address specified in cancellable_by
    /// * `vesting_obj` - The vesting object to cancel
    public entry fun cancel_vesting(
        canceller: &signer, vesting_obj: Object<Vesting>
    ) acquires Vesting {
        let canceller_addr = signer::address_of(canceller);
        let vesting_obj_addr = object::object_address(&vesting_obj);
        let vesting = borrow_global_mut<Vesting>(vesting_obj_addr);
        assert!(
            canceller_addr == vesting.cancellable_by,
            EONLY_CANCELLABLE_BY_CAN_CANCEL
        );
        // Prevent double cancellation to avoid underflow
        assert!(
            vesting.already_claimed < vesting.total_amount,
            EVESTING_ALREADY_CANCELLED
        );
        let current_time = timestamp::now_seconds();
        let total_vested =
            calculate_unlocked(
                vesting.start_timestamp,
                current_time,
                vesting.total_amount,
                vesting.duration,
                vesting.cliff_duration,
                vesting.cliff_percentage_bips
            );
        let amount_to_recipient = total_vested - vesting.already_claimed;
        let amount_to_canceller = vesting.total_amount - total_vested;
        let vesting_signer = &object::generate_signer_for_extending(&vesting.extend_ref);
        // Transfer unlocked amount to recipient
        if (amount_to_recipient > 0) {
            primary_fungible_store::transfer(
                vesting_signer,
                vesting.vesting_token,
                vesting.recipient,
                amount_to_recipient
            );
        };
        // Transfer locked amount to canceller
        if (amount_to_canceller > 0) {
            primary_fungible_store::transfer(
                vesting_signer,
                vesting.vesting_token,
                canceller_addr,
                amount_to_canceller
            );
        };
        vesting.already_claimed = vesting.total_amount;
        event::emit(
            CancelVestingEvent {
                vesting_obj_address: vesting_obj_addr,
                canceller: canceller_addr,
                amount_to_recipient,
                amount_to_canceller
            }
        );
    }

    #[view]
    public fun get_all_vestings(): vector<Object<Vesting>> acquires Vestings {
        let vestings_resource = borrow_global<Vestings>(@vesting);
        vestings_resource.vestings
    }

    #[view]
    public fun get_vesting_detail(
        vesting_obj: Object<Vesting>
    ): (u64, u64, u64, address, address, u64, u64) acquires Vesting {
        let vesting_obj_addr = object::object_address(&vesting_obj);
        let vesting = borrow_global<Vesting>(vesting_obj_addr);
        let current_time = timestamp::now_seconds();
        let total_vested =
            calculate_unlocked(
                vesting.start_timestamp,
                current_time,
                vesting.total_amount,
                vesting.duration,
                vesting.cliff_duration,
                vesting.cliff_percentage_bips
            );
        let claimable_amount = total_vested - vesting.already_claimed;
        (
            vesting.start_timestamp,
            vesting.duration,
            vesting.total_amount,
            object::object_address(&vesting.vesting_token),
            vesting.recipient,
            vesting.already_claimed,
            claimable_amount
        )
    }

    #[test_only]
    public fun init_for_test(vesting_signer: &signer) {
        init_module(vesting_signer);
    }
}

