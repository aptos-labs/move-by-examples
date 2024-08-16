module voting_app_addr::voting {
    use std::bcs;
    use std::signer;
    use std::string::String;
    use std::vector;
    use aptos_framework::object::{Self, ExtendRef, Object};
    use aptos_framework::timestamp;
    use aptos_std::string_utils;
    use aptos_framework::fungible_asset::{Self, Metadata, FungibleStore};
    use aptos_framework::primary_fungible_store;

    // ================================= Errors ================================= //
    /// Error code indicating that a live proposal already exists.
    const ERR_LIVE_PROPOSAL_ALREADY_EXISTS: u64 = 1;
    /// Error code indicating that the specified proposal does not exist.
    const ERR_PROPOSAL_DOES_NOT_EXIST: u64 = 2;
    /// Error code indicating that the proposal has already ended.
    const ERR_PROPOSAL_HAS_ENDED: u64 = 3;
    /// Error code indicating that the user has already voted on the proposal.
    const ERR_USER_ALREADY_VOTED: u64 = 4;
    /// Error code indicating that the user does not have governance tokens.
    const ERR_USER_HAS_NO_GOVERNANCE_TOKENS: u64 = 5;
    /// Error code indicating that the amount specified is zero.
    const ERR_AMOUNT_ZERO: u64 = 6;
    /// Error code indicating that the user does not have any stake.
    const ERR_USER_DOES_NOT_HAVE_STAKE: u64 = 7;
    /// Error code indicating that the user cannot unstake during a live proposal.
    const ERR_CANNOT_UNSTAKE_DURING_LIVE_PROPOSAL: u64 = 8;

    // Global for contract
    struct Proposal has key, store, drop, copy {
        id: u64,
        name: String,
        creator: address,
        start_time: u64,
        end_time: u64,
        yes_votes: u64,
        no_votes: u64,
    }

    // Global for contract
    struct ProposalRegistry has key, store {
        proposals: vector<Proposal>
    }

    // Global for construct
    struct FungibleAssetMetadata has key, store {
        // Fungible asset voters are staking to vote on
        fa_metadata_object: Object<Metadata>
    }

    // Unique for user and proposal
    struct Vote has key, store {
        voter: address,
        vote: bool, // true for yes, false for no
        amount: u64,
    }

    /// Unique per user
    struct UserStake has key, store, drop {
        // Fungible store to hold user stake
        stake_store: Object<FungibleStore>,
        // Amount of stake
        amount: u64
    }

    /// Global per contract
    /// Generate signer to send reward from reward store and stake store to user
    struct FungibleStoreController has key {
        extend_ref: ExtendRef,
    }

    /// Global per contract
    /// Generate signer to create user stake object
    struct UserStakeController has key {
        extend_ref: ExtendRef,
    }

    // This function is called once the module is published
    fun init_module(sender: &signer) {
        init_module_internal(
            sender,
            object::address_to_object<Metadata>(@fa_obj_addr)
        );
    }

    fun init_module_internal(
        sender: &signer,
        fa_metadata_object: Object<Metadata>,
    ) {
        let sender_addr = signer::address_of(sender);
        let user_stake_controller_constructor_ref = &object::create_object(sender_addr);
        move_to(sender, UserStakeController {
            extend_ref: object::generate_extend_ref(user_stake_controller_constructor_ref),
        });

        let fungible_store_constructor_ref = &object::create_object(sender_addr);
        move_to(sender, FungibleStoreController {
            extend_ref: object::generate_extend_ref(fungible_store_constructor_ref),
        });

        move_to(sender, ProposalRegistry {
            proposals: vector::empty()
        });

        move_to(sender, FungibleAssetMetadata {
            fa_metadata_object
        });
    }

    // ======================== Write functions ========================
    /// function allows sender to create a new voting proposal, duration is in seconds
    public entry fun create_proposal(sender: &signer, proposal_name: String, duration: u64) acquires ProposalRegistry {
        let proposal_registry = borrow_global_mut<ProposalRegistry>(@voting_app_addr);
        let proposal_registry_length = vector::length(&proposal_registry.proposals);
        let proposal_end_time = if(proposal_registry_length > 0){
            vector::borrow(&proposal_registry.proposals, proposal_registry_length - 1).end_time
        } else {
            0
        };

        let curr = timestamp::now_seconds();
        assert!(proposal_end_time == 0 || curr >= proposal_end_time, ERR_LIVE_PROPOSAL_ALREADY_EXISTS);
        let next_proposal_id = proposal_registry_length + 1;
        let new_proposal = Proposal {
            id: next_proposal_id,
            name: proposal_name,
            creator: signer::address_of(sender),
            start_time: curr,
            end_time: curr + duration,
            yes_votes: 0,
            no_votes: 0,
        };
        vector::push_back(&mut proposal_registry.proposals,new_proposal);
    }

    /// user can vote on a proposal
    public entry fun vote_on_proposal(sender: &signer, proposal_id: u64, vote: bool) acquires ProposalRegistry, UserStake, UserStakeController {
        let sender_addr = signer::address_of(sender);

        // Check if a proposal exists
        let proposal_registry = borrow_global_mut<ProposalRegistry>(@voting_app_addr);
        let proposal_registry_length = vector::length(&proposal_registry.proposals);
        assert!(proposal_id > 0 && proposal_id <= proposal_registry_length, ERR_PROPOSAL_DOES_NOT_EXIST);

        // Check if the proposal has ended
        let proposal = vector::borrow_mut(&mut proposal_registry.proposals, proposal_id-1);
        let curr = timestamp::now_seconds();
        assert!(curr < proposal.end_time, ERR_PROPOSAL_HAS_ENDED);

        // Check if users has already voted
        assert!(!exists<Vote>(get_vote_obj_addr(sender_addr, proposal_id)), ERR_USER_ALREADY_VOTED);

        // Check if users has staked tokens to vote
        assert!(exists_user_stake(sender_addr), ERR_USER_DOES_NOT_HAVE_STAKE);
        let user_stake_mut = borrow_global_mut<UserStake>(get_user_stake_object_address(sender_addr));
        let user_stake_amount = user_stake_mut.amount;

        // Check they have >0 tokens to vote
        assert!(user_stake_amount > 0, ERR_AMOUNT_ZERO);

        if (vote) {
            proposal.yes_votes = proposal.yes_votes + user_stake_amount;
        } else {
            proposal.no_votes = proposal.no_votes + user_stake_amount;
        };

        // create and object to store the vote for the sender
        // object seed: voting contract address + sender + proposal_id
        let vote_obj_constructor_ref = &object::create_named_object(
            sender,
            construct_object_seed(sender_addr, proposal_id)
        );
        let user_obj_signer = object::generate_signer(vote_obj_constructor_ref);
        move_to(&user_obj_signer, Vote {
            voter: sender_addr,
            vote,
            amount: user_stake_amount
        });
    }

    public entry fun stake(
        sender: &signer,
        amount: u64
    ) acquires FungibleAssetMetadata, FungibleStoreController, UserStake, UserStakeController {
        assert!(amount > 0, ERR_AMOUNT_ZERO);
        let fa_metadata = borrow_global<FungibleAssetMetadata>(@voting_app_addr);
        let sender_addr = signer::address_of(sender);
        let (stake_store, is_new_stake_store) = get_or_create_user_stake_store(
            fa_metadata.fa_metadata_object,
            sender_addr,
        );
        fungible_asset::transfer(
            sender,
            primary_fungible_store::primary_store(sender_addr, fa_metadata.fa_metadata_object),
            stake_store,
            amount
        );

        if (is_new_stake_store) {
            create_new_user_stake_object(sender_addr, stake_store);
        };

        let user_stake_mut = borrow_global_mut<UserStake>(get_user_stake_object_address(sender_addr));
        user_stake_mut.amount = user_stake_mut.amount + amount;
    }

    public entry fun unstake(
        sender: &signer
    ) acquires ProposalRegistry, FungibleAssetMetadata, FungibleStoreController, UserStake, UserStakeController {
        let sender_addr = signer::address_of(sender);

        assert!(exists_user_stake(sender_addr), ERR_USER_DOES_NOT_HAVE_STAKE);
        let user_stake = borrow_global<UserStake>(get_user_stake_object_address(sender_addr));
        let user_stake_amount = user_stake.amount;
        assert!(user_stake_amount > 0, ERR_AMOUNT_ZERO);

        let proposal_registry = borrow_global<ProposalRegistry>(@voting_app_addr);
        let proposal_registry_length = vector::length(&proposal_registry.proposals);

        // a user cannot unstake if they voted on the current live proposal
        let user_can_unstake = if (proposal_registry_length == 0) {
            true
        } else {
            // Check if the proposal has ended
            let proposal = vector::borrow(&proposal_registry.proposals, proposal_registry_length - 1);
            let curr = timestamp::now_seconds();
            if (exists<Vote>(get_vote_obj_addr(sender_addr, proposal_registry_length))) {
                // If the user has already voted, check if the proposal has ended
                curr > proposal.end_time
            } else {
                // If the user has not voted, they can unstake
                true
            }
        };

        assert!(user_can_unstake, ERR_CANNOT_UNSTAKE_DURING_LIVE_PROPOSAL);

        let fa_metadata = borrow_global<FungibleAssetMetadata>(@voting_app_addr);
        fungible_asset::transfer(
            &generate_fungible_store_signer(),
            user_stake.stake_store,
            primary_fungible_store::primary_store(sender_addr, fa_metadata.fa_metadata_object),
            user_stake_amount
        );

        let user_stake_mut = borrow_global_mut<UserStake>(get_user_stake_object_address(sender_addr));
        user_stake_mut.amount = 0;
    }

    // ======================== Read Functions ========================
    #[view]
    public fun get_proposal(proposal_id: u64): (
        u64,
        String,
        address,
        u64,
        u64,
        u64,
        u64
    ) acquires ProposalRegistry{
        let proposal = get_proposal_from_registry(proposal_id);
        (
            proposal.id,
            proposal.name,
            proposal.creator,
            proposal.start_time,
            proposal.end_time,
            proposal.yes_votes,
            proposal.no_votes
        )
    }

    #[view]
    public fun has_proposal_ended(proposal_id: u64): bool acquires ProposalRegistry {
        let proposal = get_proposal_from_registry(proposal_id);
        let curr = timestamp::now_seconds();
        curr > proposal.end_time
    }

    #[view]
    public fun get_proposal_result(proposal_id: u64): (bool, u64, u64) acquires ProposalRegistry {
        let proposal = get_proposal_from_registry(proposal_id);
        (proposal.yes_votes > proposal.no_votes, proposal.yes_votes, proposal.no_votes)
    }

    #[view]
    public fun get_vote_obj(sender: address, proposal_id: u64): Object<Vote> {
        object::address_to_object(get_vote_obj_addr(sender, proposal_id))
    }

    #[view]
    public fun get_vote_obj_addr(sender: address, proposal_id: u64): address {
        let seed = construct_object_seed(sender, proposal_id);
        object::create_object_address(&sender, seed)
    }

    #[view]
    public fun get_vote(vote_obj: Object<Vote>): (address, bool, u64) acquires Vote {
        let vote = borrow_global<Vote>(object::object_address(&vote_obj));
        (vote.voter, vote.vote, vote.amount)
    }

    #[view]
    /// Whether user has stake
    public fun exists_user_stake(user_addr: address): bool acquires UserStakeController {
        object::object_exists<UserStake>(get_user_stake_object_address(user_addr))
    }

    #[view]
    /// Get user stake amount
    public fun get_user_stake_amount(user_addr: address): u64 acquires UserStake, UserStakeController {
        let user_stake = borrow_global<UserStake>(get_user_stake_object_address(user_addr));
        user_stake.amount
    }

    // ======================== Helper Functions ========================
    /// inline to reduce overhead with a function call, performance optimization, gas etc.
    inline fun get_proposal_from_registry(proposal_id: u64): Proposal acquires ProposalRegistry {
        let proposal_registry = borrow_global<ProposalRegistry>(@voting_app_addr);
        assert!(proposal_id > 0 && proposal_id <= vector::length(&proposal_registry.proposals), ERR_PROPOSAL_DOES_NOT_EXIST);
        *vector::borrow(&proposal_registry.proposals, proposal_id - 1)
    }

    fun construct_object_seed(sender: address, proposal_registry_length: u64 ): vector<u8> {
        bcs::to_bytes(&string_utils::format3(&b"{}_user_{}_proposal_{}",
            @voting_app_addr,
            sender,
            proposal_registry_length
            )
        )
    }

    /// Get or create user stake store
    /// If user does not have stake store, create one
    /// Returns (user_stake.stake_store, is_new_stake_store)
    fun get_or_create_user_stake_store(
        fa_metadata_object: Object<Metadata>,
        user_addr: address,
    ): (Object<FungibleStore>, bool) acquires FungibleStoreController, UserStake, UserStakeController {
        let store_signer = &generate_fungible_store_signer();
        let user_stake_object_addr = get_user_stake_object_address(user_addr);
        if (object::object_exists<UserStake>(user_stake_object_addr)) {
            let user_stake = borrow_global<UserStake>(user_stake_object_addr);
            (user_stake.stake_store, false)
        } else {
            let stake_store_object_constructor_ref = &object::create_object(signer::address_of(store_signer));
            let stake_store = fungible_asset::create_store(
                stake_store_object_constructor_ref,
                fa_metadata_object,
            );
            (stake_store, true)
        }
    }

    /// Create new user stake entry with default values
    fun create_new_user_stake_object(
        user_addr: address,
        stake_store: Object<FungibleStore>,
    ) acquires UserStakeController {
        let user_stake_object_constructor_ref = &object::create_named_object(
            &generate_user_stake_object_signer(),
            construct_user_stake_object_seed(user_addr),
        );
        move_to(&object::generate_signer(user_stake_object_constructor_ref), UserStake {
            stake_store,
            amount: 0,
        });
    }

    /// Generate signer to send reward from reward store and stake store to user
    fun generate_fungible_store_signer(): signer acquires FungibleStoreController {
        object::generate_signer_for_extending(&borrow_global<FungibleStoreController>(@voting_app_addr).extend_ref)
    }

    /// Generate signer to create user stake object
    fun generate_user_stake_object_signer(): signer acquires UserStakeController {
        object::generate_signer_for_extending(&borrow_global<UserStakeController>(@voting_app_addr).extend_ref)
    }

    /// Construct user stake object seed
    fun construct_user_stake_object_seed(user_addr: address): vector<u8> {
        bcs::to_bytes(&string_utils::format2(&b"{}_staker_{}", @voting_app_addr, user_addr))
    }

    fun get_user_stake_object_address(user_addr: address): address acquires UserStakeController {
        object::create_object_address(
            &signer::address_of(&generate_user_stake_object_signer()),
            construct_user_stake_object_seed(user_addr)
        )
    }

    // ======================== Unit Tests ========================
    #[test_only]
    public fun init_module_for_test_with_fa(
        aptos_framework: &signer,
        sender: &signer,
        fa_metadata_object: Object<Metadata>,
    ) {
        timestamp::set_time_has_started_for_testing(aptos_framework);

        init_module_internal(
            sender,
            fa_metadata_object,
        );
    }
}