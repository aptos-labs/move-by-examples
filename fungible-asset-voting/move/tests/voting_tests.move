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

        let (name, creator, start_time, end_time, yes_votes, no_votes) = voting::most_recent_proposal();
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
        voting::vote_on_proposal(alice, true, 10);

        let (name, creator, start_time, end_time, yes_votes, no_votes) = voting::most_recent_proposal();
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
        voting::vote_on_proposal(alice, true, 10);

        let (name, creator, start_time, end_time, yes_votes, no_votes) = voting::most_recent_proposal();
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
        voting::vote_on_proposal(alice, true, 10);
    }
}