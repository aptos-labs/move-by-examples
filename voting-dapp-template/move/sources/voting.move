module voting_addr::voting {
    use std::bcs;
    use std::signer;
    use std::string::String;
    use std::vector;
    use std::option;
    use std::option::Option;
    use aptos_framework::object::{Self, Object};
    use aptos_framework::timestamp;
    use aptos_std::string_utils;

    // Error Codes
    const E_PROPOSAL_DOES_NOT_EXIST: u64 = 1;
    const E_USER_HAS_NO_GOVERNANCE_TOKENS: u64 = 2;
    const E_USER_ALREADY_VOTED: u64 = 3;
    const E_PROPOSAL_HAS_ENDED: u64 = 4;

    // Global for contract
    struct Proposal has key, store, drop, copy {
        name: Option<String>,
        creator: address,
        start_time: u64,
        end_time: u64,
        yes_votes: u64,
        no_votes: u64,
    }

    // Global for contract
    struct ProposalRegistry has key, store, drop {
        proposals: vector<Proposal>
    }

    // Unique for user
    struct Vote has key, store {
        voter: address,
        vote: bool, // true for yes, false for no
        amount: u64,
    }

    // This function is called once the module is published
    fun init_module(sender: &signer) {
        move_to(sender, ProposalRegistry {
            proposals: vector::empty(),
        });
    }

    // ======================== Write functions ========================
    // function allows sender to create a new voting proposal
    // There will be a start_time, end_time, and a name for the proposal
    public entry fun create_proposal(sender: &signer, proposal_name: String, duration: u64) acquires ProposalRegistry {
        let proposal_registry = borrow_global_mut<ProposalRegistry>(@voting_addr);
        let curr = timestamp::now_seconds();
        let new_proposal = Proposal {
            name: option::some(proposal_name),
            creator: signer::address_of(sender),
            start_time: curr,
            end_time: curr + duration,
            yes_votes: 0,
            no_votes: 0,
        };
        vector::push_back(&mut proposal_registry.proposals,new_proposal);
    }

    // write function that allows a user to vote on a proposal
    public entry fun vote_on_proposal(sender: &signer, vote: bool, amount: u64) acquires ProposalRegistry {
        // Check if a proposal exists
        let proposal_registry = borrow_global_mut<ProposalRegistry>(@voting_addr);
        let proposal_registry_length = vector::length(&proposal_registry.proposals);
        assert!(proposal_registry_length > 0, E_PROPOSAL_DOES_NOT_EXIST);

        // Check if the proposal has ended
        let proposal = vector::borrow_mut(&mut proposal_registry.proposals, proposal_registry_length-1);
        let curr = timestamp::now_seconds();
        assert!(curr < proposal.end_time, E_PROPOSAL_HAS_ENDED);

        // Check if users has already voted
        assert!(!exists<Vote>(get_vote_obj_addr(signer::address_of(sender), proposal_registry_length)), E_USER_ALREADY_VOTED);

        if (vote) {
            proposal.yes_votes = proposal.yes_votes + amount;
        } else {
            proposal.no_votes = proposal.no_votes + amount;
        };

        // create and object to store the vote for the sender
        // object seed: voting contract address + sender + proposal_registry_length
        let user_obj_constructor_ref = &object::create_named_object(
            sender,
            construct_object_seed(signer::address_of(sender), proposal_registry_length)
        );
        let user_obj_signer = object::generate_signer(user_obj_constructor_ref);
        move_to(&user_obj_signer, Vote {
            voter: signer::address_of(sender),
            vote,
            amount,
        });
    }

    // ======================== Read Functions ========================
    public fun current_proposal(): (
        Option<String>,
        address,
        u64,
        u64,
        u64,
        u64
    ) acquires ProposalRegistry{
        let proposal = get_proposal_from_registry();
        (
            proposal.name,
            proposal.creator,
            proposal.start_time,
            proposal.end_time,
            proposal.yes_votes,
            proposal.no_votes
        )
    }

    public fun has_proposal_ended(): bool acquires ProposalRegistry {
        let proposal = get_proposal_from_registry();
        let curr = timestamp::now_seconds();
        curr > proposal.end_time
    }

    public fun current_proposal_result(): (bool, u64, u64) acquires ProposalRegistry {
        let proposal = get_proposal_from_registry();
        (proposal.yes_votes > proposal.no_votes, proposal.yes_votes, proposal.no_votes)
    }

    public fun get_vote_obj(sender: address, proposal_registry_length: u64): Object<Vote> {
        let seed = construct_object_seed(sender, proposal_registry_length);
        object::address_to_object(object::create_object_address(&sender, seed))
    }

    public fun get_vote_obj_addr(sender: address, proposal_registry_length: u64): address {
        let seed = construct_object_seed(sender, proposal_registry_length);
        object::create_object_address(&sender, seed)
    }

    public fun get_vote(vote_obj: Object<Vote>): (address, bool, u64) acquires Vote {
        let vote = borrow_global<Vote>(object::object_address(&vote_obj));
        (vote.voter, vote.vote, vote.amount)
    }

    // ======================== Helper Functions ========================
    // reduce overhead with a function call, performance optimization, gas etc.
    inline fun get_proposal_from_registry(): Proposal acquires ProposalRegistry {
        let proposal_registry = borrow_global<ProposalRegistry>(@voting_addr);
        assert!(vector::length(&proposal_registry.proposals) > 0, E_PROPOSAL_DOES_NOT_EXIST);
        *vector::borrow(&proposal_registry.proposals, vector::length(&proposal_registry.proposals) - 1)
    }

    fun construct_object_seed(sender: address, proposal_registry_length: u64 ): vector<u8> {
        bcs::to_bytes(&string_utils::format3(&b"{}_user_{}_proposal_{}",
            @voting_addr,
            sender,
            proposal_registry_length
            )
        )
    }

    // ======================== Unit Tests ========================
    #[test_only]
    use std::string;

    #[test(aptos_framework = @std, owner = @voting_addr, alice = @0x1234)]
    fun test_create_proposal(aptos_framework: &signer, owner: &signer, alice: &signer) acquires ProposalRegistry {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::update_global_time_for_test_secs(1000);
        init_module(owner);
        let proposal_registry = borrow_global<ProposalRegistry>(@voting_addr);
        assert!(vector::length(&proposal_registry.proposals) == 0, 1);

        create_proposal(alice, string::utf8(b"Test Proposal"), 100);
        let proposal_registry_after = borrow_global<ProposalRegistry>(@voting_addr);
        assert!(vector::length(&proposal_registry_after.proposals) == 1, 1);
        assert!(vector::borrow(&proposal_registry_after.proposals, 0).name == option::some(string::utf8(b"Test Proposal")), 1);
        assert!(vector::borrow(&proposal_registry_after.proposals, 0).creator == signer::address_of(alice), 1);
        assert!(vector::borrow(&proposal_registry_after.proposals, 0).start_time == 1000, 1);
        assert!(vector::borrow(&proposal_registry_after.proposals, 0).end_time == 1100, 1);
        assert!(vector::borrow(&proposal_registry_after.proposals, 0).yes_votes == 0, 1);
        assert!(vector::borrow(&proposal_registry_after.proposals, 0).no_votes == 0, 1);
    }

    #[test(aptos_framework = @std, owner = @voting_addr, alice = @0x1234)]
    fun test_vote_on_proposal(aptos_framework: &signer, owner: &signer, alice: &signer) acquires ProposalRegistry, Vote{
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::update_global_time_for_test_secs(1000);
        init_module(owner);
        create_proposal(alice, string::utf8(b"Test Proposal"), 100);
        vote_on_proposal(alice, true, 10);

        let proposal = get_proposal_from_registry();
        assert!(proposal.name == option::some(string::utf8(b"Test Proposal")), 1);
        assert!(proposal.creator == signer::address_of(alice), 1);
        assert!(proposal.start_time == 1000, 1);
        assert!(proposal.end_time == 1100, 1);
        assert!(proposal.yes_votes == 10, 1);
        assert!(proposal.no_votes == 0, 1);

        let vote_obj = get_vote_obj(signer::address_of(alice), 1);
        let (voter, vote, amount) = get_vote(vote_obj);
        assert!(voter == signer::address_of(alice), 1);
        assert!(vote == true, 1);
        assert!(amount == 10, 1);
    }

    #[test(aptos_framework = @std, owner = @voting_addr, alice = @0x1234)]
    #[expected_failure(abort_code = E_USER_ALREADY_VOTED, location = Self)]
    fun test_vote_on_proposal_twice_error(aptos_framework: &signer, owner: &signer, alice: &signer) acquires ProposalRegistry, Vote{
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::update_global_time_for_test_secs(1000);
        init_module(owner);
        create_proposal(alice, string::utf8(b"Test Proposal"), 100);
        vote_on_proposal(alice, true, 10);

        let proposal = get_proposal_from_registry();
        assert!(proposal.name == option::some(string::utf8(b"Test Proposal")), 1);
        assert!(proposal.creator == signer::address_of(alice), 1);
        assert!(proposal.start_time == 1000, 1);
        assert!(proposal.end_time == 1100, 1);
        assert!(proposal.yes_votes == 10, 1);
        assert!(proposal.no_votes == 0, 1);

        let vote_obj = get_vote_obj(signer::address_of(alice), 1);
        let (voter, vote, amount) = get_vote(vote_obj);
        assert!(voter == signer::address_of(alice), 1);
        assert!(vote == true, 1);
        assert!(amount == 10, 1);
        vote_on_proposal(alice, true, 10);
    }
}