module voting_app_addr::voting {
    use std::bcs;
    use std::signer;
    use std::string::String;
    use std::vector;
    use aptos_framework::object::{Self, Object};
    use aptos_framework::timestamp;
    use aptos_std::string_utils;

    // Error Codes
    const ERR_PROPOSAL_DOES_NOT_EXIST: u64 = 1;
    const ERR_USER_HAS_NO_GOVERNANCE_TOKENS: u64 = 2;
    const ERR_USER_ALREADY_VOTED: u64 = 3;
    const ERR_PROPOSAL_HAS_ENDED: u64 = 4;

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
    /// function allows sender to create a new voting proposal
    public entry fun create_proposal(sender: &signer, proposal_name: String, duration: u64) acquires ProposalRegistry {
        let proposal_registry = borrow_global_mut<ProposalRegistry>(@voting_app_addr);
        let proposal_registry_length = vector::length(&proposal_registry.proposals) + 1;
        let curr = timestamp::now_seconds();
        let new_proposal = Proposal {
            id: proposal_registry_length,
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
    public entry fun vote_on_proposal(sender: &signer, proposal_id: u64, vote: bool, amount: u64) acquires ProposalRegistry {
        let sender_addr = signer::address_of(sender);

        // Check if a proposal exists
        let proposal_registry = borrow_global_mut<ProposalRegistry>(@voting_app_addr);
        let proposal_registry_length = vector::length(&proposal_registry.proposals);
        assert!(proposal_id <= proposal_registry_length, ERR_PROPOSAL_DOES_NOT_EXIST);

        // Check if the proposal has ended
        let proposal = vector::borrow_mut(&mut proposal_registry.proposals, proposal_id-1);
        let curr = timestamp::now_seconds();
        assert!(curr < proposal.end_time, ERR_PROPOSAL_HAS_ENDED);

        // Check if users has already voted
        assert!(!exists<Vote>(get_vote_obj_addr(sender_addr, proposal_id)), ERR_USER_ALREADY_VOTED);

        if (vote) {
            proposal.yes_votes = proposal.yes_votes + amount;
        } else {
            proposal.no_votes = proposal.no_votes + amount;
        };

        // create and object to store the vote for the sender
        // object seed: voting contract address + sender + proposal_id
        let user_obj_constructor_ref = &object::create_named_object(
            sender,
            construct_object_seed(sender_addr, proposal_id)
        );
        let user_obj_signer = object::generate_signer(user_obj_constructor_ref);
        move_to(&user_obj_signer, Vote {
            voter: sender_addr,
            vote,
            amount,
        });
    }

    // ======================== Read Functions ========================
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

    public fun has_proposal_ended(proposal_id: u64): bool acquires ProposalRegistry {
        let proposal = get_proposal_from_registry(proposal_id);
        let curr = timestamp::now_seconds();
        curr > proposal.end_time
    }

    public fun get_proposal_result(proposal_id: u64): (bool, u64, u64) acquires ProposalRegistry {
        let proposal = get_proposal_from_registry(proposal_id);
        (proposal.yes_votes > proposal.no_votes, proposal.yes_votes, proposal.no_votes)
    }

    public fun get_vote_obj(sender: address, proposal_id: u64): Object<Vote> {
        let seed = construct_object_seed(sender, proposal_id);
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
    /// inline to reduce overhead with a function call, performance optimization, gas etc.
    inline fun get_proposal_from_registry(proposal_id: u64): Proposal acquires ProposalRegistry {
        let proposal_registry = borrow_global<ProposalRegistry>(@voting_app_addr);
        assert!(proposal_id <= vector::length(&proposal_registry.proposals), ERR_PROPOSAL_DOES_NOT_EXIST);
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

    // ======================== Unit Tests ========================
    #[test_only]
    public fun init_module_for_test(sender: &signer) {
        init_module(sender);
    }
}