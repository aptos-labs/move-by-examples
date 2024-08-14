#[test_only]
module voting_app_addr::voting_tests {
    use std::signer;
    use aptos_framework::timestamp;
    use std::string;

    use voting_app_addr::voting;

    #[test(aptos_framework = @std, owner = @voting_app_addr, alice = @0x1234)]
    fun test_create_proposal(aptos_framework: &signer, owner: &signer, alice: &signer) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::update_global_time_for_test_secs(1000);
        voting::init_module_for_test(owner);
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
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::update_global_time_for_test_secs(1000);
        voting::init_module_for_test(owner);
        voting::create_proposal(alice, string::utf8(b"Test Proposal"), 100);
        voting::vote_on_proposal(alice, 1,true, 10);

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
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::update_global_time_for_test_secs(1000);
        voting::init_module_for_test(owner);
        voting::create_proposal(alice, string::utf8(b"Test Proposal"), 100);
        voting::vote_on_proposal(alice, 1,true, 10);

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
        voting::vote_on_proposal(alice,1, true, 10);
    }

    #[test(aptos_framework = @std, owner = @voting_app_addr, alice = @0x1234, bob = @0x5678)]
    fun test_happy_path_2_proposals(aptos_framework: &signer, owner: &signer, alice: &signer, bob: &signer) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::update_global_time_for_test_secs(1000);
        voting::init_module_for_test(owner);

        // create two proposals
        voting::create_proposal(alice, string::utf8(b"Test Proposal 1"), 100);
        timestamp::update_global_time_for_test_secs(1005);
        voting::create_proposal(bob, string::utf8(b"Test Proposal 2"), 100);

        // vote on two proposals
        voting::vote_on_proposal(alice, 1,true, 10);
        voting::vote_on_proposal(bob, 1,false, 5);
        voting::vote_on_proposal(alice, 2,false, 10);
        voting::vote_on_proposal(bob, 2,true, 5);

        let (id, name, creator, start_time, end_time, yes_votes, no_votes) = voting::get_proposal(1);
        assert!(id == 1, 1);
        assert!(name == string::utf8(b"Test Proposal 1"), 1);
        assert!(creator == signer::address_of(alice), 1);
        assert!(start_time == 1000, 1);
        assert!(end_time == 1100, 1);
        assert!(yes_votes == 10, 1);
        assert!(no_votes == 5, 1);

        let (id, name, creator, start_time, end_time, yes_votes, no_votes) = voting::get_proposal(2);
        assert!(id == 2, 1);
        assert!(name == string::utf8(b"Test Proposal 2"), 1);
        assert!(creator == signer::address_of(bob), 1);
        assert!(start_time == 1005, 1);
        assert!(end_time == 1105, 1);
        assert!(yes_votes == 5, 1);
        assert!(no_votes == 10, 1);

        // check vote objects
        let vote_obj = voting::get_vote_obj(signer::address_of(alice), 1);
        let (voter, vote, amount) = voting::get_vote(vote_obj);
        assert!(voter == signer::address_of(alice), 1);
        assert!(vote == true, 1);
        assert!(amount == 10, 1);

        let vote_obj = voting::get_vote_obj(signer::address_of(alice), 2);
        let (voter, vote, amount) = voting::get_vote(vote_obj);
        assert!(voter == signer::address_of(alice), 1);
        assert!(vote == false, 1);
        assert!(amount == 10, 1);

        let vote_obj = voting::get_vote_obj(signer::address_of(bob), 1);
        let (voter, vote, amount) = voting::get_vote(vote_obj);
        assert!(voter == signer::address_of(bob), 1);
        assert!(vote == false, 1);
        assert!(amount == 5, 1);

        let vote_obj = voting::get_vote_obj(signer::address_of(bob), 2);
        let (voter, vote, amount) = voting::get_vote(vote_obj);
        assert!(voter == signer::address_of(bob), 1);
        assert!(vote == true, 1);
        assert!(amount == 5, 1);

        // check if proposals has ended
        assert!(voting::has_proposal_ended(1) == false, 1);
        assert!(voting::has_proposal_ended(2) == false, 1);
        timestamp::update_global_time_for_test_secs(1106);
        assert!(voting::has_proposal_ended(1) == true, 1);
        assert!(voting::has_proposal_ended(2) == true, 1);

        let (pass, yes_votes, no_votes) = voting::get_proposal_result(1);
        assert!(pass == true, 1);
        assert!(yes_votes == 10, 1);
        assert!(no_votes == 5, 1);

        let (pass, yes_votes, no_votes) = voting::get_proposal_result(2);
        assert!(pass == false, 1);
        assert!(yes_votes == 5, 1);
        assert!(no_votes == 10, 1);
    }
}