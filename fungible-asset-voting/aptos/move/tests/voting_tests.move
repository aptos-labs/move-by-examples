#[test_only]
module voting_app_addr::voting_tests {
    use std::signer;
    use aptos_framework::timestamp;
    use std::string;
    use aptos_framework::fungible_asset::{Self, Metadata};
    use aptos_framework::object;
    use aptos_framework::primary_fungible_store;
    use std::option;

    use voting_app_addr::voting;

    #[test(aptos_framework = @std, owner = @voting_app_addr, alice = @0x1234)]
    fun test_create_proposal(aptos_framework: &signer, owner: &signer, alice: &signer) {
        setup_fa(aptos_framework, owner, alice);
        voting::stake(alice, 10);
        voting::create_proposal(alice, string::utf8(b"Test Proposal"), 100);

        let (id, name, creator, start_time, end_time, yes_votes, no_votes) = voting::get_proposal(1);
        assert!(id == 1, 1);
        assert!(name == string::utf8(b"Test Proposal"), 1);
        assert!(creator == signer::address_of(alice), 1);
        assert!(start_time == 1000, 1);
        assert!(end_time == 1100, 1);
        assert!(yes_votes == 0, 1);
        assert!(no_votes == 0, 1);
    }

    #[test(aptos_framework = @std, owner = @voting_app_addr, alice = @0x1234)]
    fun test_vote_on_proposal(aptos_framework: &signer, owner: &signer, alice: &signer) {
        setup_fa(aptos_framework, owner, alice);
        voting::stake(alice, 10);

        voting::create_proposal(alice, string::utf8(b"Test Proposal"), 100);
        voting::vote_on_proposal(alice, 1,true);

        let (id, name, creator, start_time, end_time, yes_votes, no_votes) = voting::get_proposal(1);
        assert!(id == 1, 1);
        assert!(name == string::utf8(b"Test Proposal"), 1);
        assert!(creator == signer::address_of(alice), 1);
        assert!(start_time == 1000, 1);
        assert!(end_time == 1100, 1);
        assert!(yes_votes == 10, 1);
        assert!(no_votes == 0, 1);

        let vote_obj = voting::get_vote_obj(signer::address_of(alice), 1);
        let (voter, vote, amount) = voting::get_vote(vote_obj);
        assert!(voter == signer::address_of(alice), 1);
        assert!(vote == true, 1);
        assert!(amount == 10, 1);
    }

    #[test(aptos_framework = @std, owner = @voting_app_addr, alice = @0x1234)]
    #[expected_failure(abort_code = voting::ERR_USER_ALREADY_VOTED)]
    fun test_vote_on_proposal_twice_error(aptos_framework: &signer, owner: &signer, alice: &signer) {
        setup_fa(aptos_framework, owner, alice);
        voting::stake(alice, 10);

        voting::create_proposal(alice, string::utf8(b"Test Proposal"), 100);
        voting::vote_on_proposal(alice, 1,true);

        let (id, name, creator, start_time, end_time, yes_votes, no_votes) = voting::get_proposal(1);
        assert!(id == 1, 1);
        assert!(name == string::utf8(b"Test Proposal"), 1);
        assert!(creator == signer::address_of(alice), 1);
        assert!(start_time == 1000, 1);
        assert!(end_time == 1100, 1);
        assert!(yes_votes == 10, 1);
        assert!(no_votes == 0, 1);

        let vote_obj = voting::get_vote_obj(signer::address_of(alice), 1);
        let (voter, vote, amount) = voting::get_vote(vote_obj);
        assert!(voter == signer::address_of(alice), 1);
        assert!(vote == true, 1);
        assert!(amount == 10, 1);
        voting::vote_on_proposal(alice,1, true);
    }

    #[test(aptos_framework = @std, owner = @voting_app_addr, alice = @0x1234, bob = @0x5678)]
    fun test_happy_path_1_proposal_2_voters(aptos_framework: &signer, owner: &signer, alice: &signer, bob: &signer) {
        setup_fa_2_voters(aptos_framework, owner, alice, bob);

        // stake tokens for voting
        voting::stake(alice, 10);
        voting::stake(bob, 5);

        // create a proposal
        voting::create_proposal(alice, string::utf8(b"Test Proposal 1"), 100);

        // vote on proposal
        voting::vote_on_proposal(alice, 1,true);
        voting::vote_on_proposal(bob, 1,false);

        let (id, name, creator, start_time, end_time, yes_votes, no_votes) = voting::get_proposal(1);
        assert!(id == 1, 1);
        assert!(name == string::utf8(b"Test Proposal 1"), 1);
        assert!(creator == signer::address_of(alice), 1);
        assert!(start_time == 1000, 1);
        assert!(end_time == 1100, 1);
        assert!(yes_votes == 10, 1);
        assert!(no_votes == 5, 1);

        // check vote objects
        let vote_obj = voting::get_vote_obj(signer::address_of(alice), 1);
        let (voter, vote, amount) = voting::get_vote(vote_obj);
        assert!(voter == signer::address_of(alice), 1);
        assert!(vote == true, 1);
        assert!(amount == 10, 1);

        let vote_obj = voting::get_vote_obj(signer::address_of(bob), 1);
        let (voter, vote, amount) = voting::get_vote(vote_obj);
        assert!(voter == signer::address_of(bob), 1);
        assert!(vote == false, 1);
        assert!(amount == 5, 1);

        // check if proposals has ended
        assert!(voting::has_proposal_ended(1) == false, 1);
        timestamp::update_global_time_for_test_secs(1101);
        assert!(voting::has_proposal_ended(1) == true, 1);

        let (pass, yes_votes, no_votes) = voting::get_proposal_result(1);
        assert!(pass == true, 1);
        assert!(yes_votes == 10, 1);
        assert!(no_votes == 5, 1);

        // create a second proposal after first one ended
        voting::create_proposal(bob, string::utf8(b"Test Proposal 2"), 100);
    }

    #[test(
        aptos_framework = @std,
        sender = @voting_app_addr,
        staker1 = @0x101
    )]
    fun test_happy_path_stake(
        aptos_framework: &signer,
        sender: &signer,
        staker1: &signer
    ) {
        setup_fa(aptos_framework, sender, staker1);
        voting::stake(staker1, 20000);
    }

    #[test(
        aptos_framework = @std,
        sender = @voting_app_addr,
        staker1 = @0x101
    )]
    fun test_happy_path_unstake(
        aptos_framework: &signer,
        sender: &signer,
        staker1: &signer
    ) {
        let sender_addr = signer::address_of(staker1);
        setup_fa(aptos_framework, sender, staker1);
        voting::stake(staker1, 20000);
        assert!(voting::get_user_stake_amount(sender_addr) == 20000, 1);
        voting::unstake(staker1);
        assert!(voting::get_user_stake_amount(sender_addr) == 0, 1);
    }

    #[test(aptos_framework = @std, owner = @voting_app_addr, alice = @0x1234)]
    #[expected_failure(abort_code = voting::ERR_CANNOT_UNSTAKE_DURING_LIVE_PROPOSAL)]
    fun test_user_cannot_unstake(aptos_framework: &signer, owner: &signer, alice: &signer) {
        setup_fa(aptos_framework, owner, alice);
        voting::stake(alice, 10);
        voting::create_proposal(alice, string::utf8(b"Test Proposal"), 100);
        voting::vote_on_proposal(alice, 1,true);
        voting::unstake(alice);
    }

    #[test(aptos_framework = @std, owner = @voting_app_addr, alice = @0x1234)]
    fun test_user_can_unstake_after_proposal_end(aptos_framework: &signer, owner: &signer, alice: &signer) {
        setup_fa(aptos_framework, owner, alice);
        voting::stake(alice, 10);
        voting::create_proposal(alice, string::utf8(b"Test Proposal"), 100);
        voting::vote_on_proposal(alice, 1,true);
        timestamp::update_global_time_for_test_secs(1101);
        voting::unstake(alice);
        assert!(voting::get_user_stake_amount(signer::address_of(alice)) == 0, 1);
    }

    fun setup_fa(aptos_framework: &signer, owner: &signer, alice: &signer){
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::update_global_time_for_test_secs(1000);


        let owner_addr = signer::address_of(owner);
        let staker1_stake_amount = 20000;

        let fa_obj_constructor_ref = &object::create_sticky_object(owner_addr);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            fa_obj_constructor_ref,
            option::none(),
            string::utf8(b"Test FA for staking"),
            string::utf8(b"TFAS"),
            8,
            string::utf8(b"url"),
            string::utf8(b"url"),
        );
        primary_fungible_store::mint(
            &fungible_asset::generate_mint_ref(fa_obj_constructor_ref),
            signer::address_of(alice),
            staker1_stake_amount
        );

        voting::init_module_for_test_with_fa(aptos_framework,owner, object::object_from_constructor_ref<Metadata>(fa_obj_constructor_ref));
    }

    fun setup_fa_2_voters(aptos_framework: &signer, owner: &signer, alice: &signer, bob: &signer){
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::update_global_time_for_test_secs(1000);


        let owner_addr = signer::address_of(owner);
        let staker1_stake_amount = 20000;
        let staker2_stake_amount = 10000;


        let fa_obj_constructor_ref = &object::create_sticky_object(owner_addr);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            fa_obj_constructor_ref,
            option::none(),
            string::utf8(b"Test FA for staking"),
            string::utf8(b"TFAS"),
            8,
            string::utf8(b"url"),
            string::utf8(b"url"),
        );
        primary_fungible_store::mint(
            &fungible_asset::generate_mint_ref(fa_obj_constructor_ref),
            signer::address_of(alice),
            staker1_stake_amount
        );
        primary_fungible_store::mint(
            &fungible_asset::generate_mint_ref(fa_obj_constructor_ref),
            signer::address_of(bob),
            staker2_stake_amount
        );

        voting::init_module_for_test_with_fa(aptos_framework,owner, object::object_from_constructor_ref<Metadata>(fa_obj_constructor_ref));
    }
}