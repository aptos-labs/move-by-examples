#[test_only]
module aptos_friend_addr::test_end_to_end {
    use std::signer;
    use std::string;
    use std::vector;

    use aptos_framework::account;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin;

    use aptos_friend_addr::aptos_friend;

    #[test(aptos_framework = @aptos_framework, deployer = @aptos_friend_addr, user_1 = @0x998, user_2 = @0x997)]
    fun test_happy_path(
        aptos_framework: &signer,
        deployer: &signer,
        user_1: &signer,
        user_2: &signer,
    ) {
        // ================================= Setup ================================== //

        let user_1_addr = signer::address_of(user_1);
        let user_2_addr = signer::address_of(user_2);

        let (burn_cap, mint_cap) = aptos_friend::init_module_for_test(aptos_framework, deployer);

        account::create_account_for_test(user_1_addr);
        coin::register<AptosCoin>(user_1);

        account::create_account_for_test(user_2_addr);
        coin::register<AptosCoin>(user_2);

        // ================================= User 1 issues share ================================== //

        aptos_friend::issue_share(user_1, string::utf8(b"test_user_1"));
        let issuer_1_obj = aptos_friend::get_issuer_obj(user_1_addr);

        {
            let (
                addr,
                username,
                total_issued_shares,
            ) = aptos_friend::get_issuer(issuer_1_obj);
            let holder_holdings = aptos_friend::get_issuer_holder_holdings(issuer_1_obj);
            assert!(addr == user_1_addr, 1);
            assert!(username == string::utf8(b"test_user_1"), 1);
            assert!(total_issued_shares == 1, 1);
            assert!(vector::length(&holder_holdings) == 1, 1);
            assert!(vector::borrow(&holder_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_1_addr), 1);
        };

        {
            let user_obj = aptos_friend::get_user_obj(user_1_addr);
            let user_holdings = aptos_friend::get_user_holdings(user_obj);
            assert!(vector::length(&user_holdings) == 1, 2);
            assert!(vector::borrow(&user_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_1_addr), 1);
        };

        {
            let holding_obj = aptos_friend::get_holding_obj(user_1_addr, user_1_addr);
            let (issuer, holder, shares) = aptos_friend::get_holding(holding_obj);
            assert!(issuer == user_1_addr, 3);
            assert!(holder == user_1_addr, 3);
            assert!(shares == 1, 3);
        };

        // ================================= User 1 buy 10 shares of its own share ================================== //

        let (share_cost_1, issuer_fee_1, protocol_fee_1, total_cost_1) = aptos_friend::calculate_buy_share_cost(
            issuer_1_obj,
            10
        );
        let coins = coin::mint(total_cost_1, &mint_cap);
        coin::deposit(user_1_addr, coins);

        aptos_friend::buy_share(user_1, issuer_1_obj, 10);
        assert!(coin::balance<AptosCoin>(user_1_addr) == issuer_fee_1, 4);
        assert!(coin::balance<AptosCoin>(aptos_friend::get_vault_addr()) == share_cost_1, 4);
        assert!(coin::balance<AptosCoin>(@aptos_friend_addr) == protocol_fee_1, 4);

        {
            let (_, _, total_issued_shares) = aptos_friend::get_issuer(issuer_1_obj);
            let holder_holdings = aptos_friend::get_issuer_holder_holdings(issuer_1_obj);
            assert!(total_issued_shares == 11, 5);
            assert!(vector::length(&holder_holdings) == 1, 5);
            assert!(vector::borrow(&holder_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_1_addr), 5);
        };

        {
            let user_obj = aptos_friend::get_user_obj(user_1_addr);
            let user_holdings = aptos_friend::get_user_holdings(user_obj);
            assert!(vector::length(&user_holdings) == 1, 6);
            assert!(vector::borrow(&user_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_1_addr), 6);
        };

        {
            let holding_obj = aptos_friend::get_holding_obj(user_1_addr, user_1_addr);
            let (_, _, shares) = aptos_friend::get_holding(holding_obj);
            assert!(shares == 11, 7);
        };

        // ================================= User 2 buy 5 shares of user 1's share ================================== //

        let (share_cost_2, issuer_fee_2, protocol_fee_2, total_cost_2) = aptos_friend::calculate_buy_share_cost(
            issuer_1_obj,
            5
        );
        let coins = coin::mint(total_cost_2, &mint_cap);
        coin::deposit(user_2_addr, coins);

        aptos_friend::buy_share(user_2, issuer_1_obj, 5);
        assert!(coin::balance<AptosCoin>(user_2_addr) == 0, 8);
        assert!(coin::balance<AptosCoin>(user_1_addr) == issuer_fee_1 + issuer_fee_2, 8);
        assert!(coin::balance<AptosCoin>(aptos_friend::get_vault_addr()) == share_cost_1 + share_cost_2, 8);
        assert!(coin::balance<AptosCoin>(@aptos_friend_addr) == protocol_fee_1 + protocol_fee_2, 8);

        {
            let (_, _, total_issued_shares) = aptos_friend::get_issuer(issuer_1_obj);
            let holder_holdings = aptos_friend::get_issuer_holder_holdings(issuer_1_obj);
            assert!(total_issued_shares == 16, 9);
            assert!(vector::length(&holder_holdings) == 2, 9);
            assert!(vector::borrow(&holder_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_1_addr), 9);
            assert!(vector::borrow(&holder_holdings, 1) == &aptos_friend::get_holding_obj(user_1_addr, user_2_addr), 9);
        };

        {
            let user_1_obj = aptos_friend::get_user_obj(user_1_addr);
            let user_1_holdings = aptos_friend::get_user_holdings(user_1_obj);
            assert!(vector::length(&user_1_holdings) == 1, 10);
            assert!(
                vector::borrow(&user_1_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_1_addr),
                10
            );

            let user_2_obj = aptos_friend::get_user_obj(user_2_addr);
            let user_2_holdings = aptos_friend::get_user_holdings(user_2_obj);
            assert!(vector::length(&user_2_holdings) == 1, 10);
            assert!(
                vector::borrow(&user_2_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_2_addr),
                10
            );
        };

        {
            let holding_obj = aptos_friend::get_holding_obj(user_1_addr, user_2_addr);
            let (_, _, shares) = aptos_friend::get_holding(holding_obj);
            assert!(shares == 5, 11);
        };

        // ================================= User 1 sell 3 shares of its own share ================================== //

        let (share_cost_3, issuer_fee_3, protocol_fee_3, total_cost_3) = aptos_friend::calculate_sell_share_cost(
            issuer_1_obj,
            3
        );
        let coins = coin::mint(total_cost_3, &mint_cap);
        coin::deposit(user_1_addr, coins);

        aptos_friend::sell_share(user_1, issuer_1_obj, 3);
        assert!(
            coin::balance<AptosCoin>(
                user_1_addr
            ) == issuer_fee_1 + issuer_fee_2 + issuer_fee_3 + share_cost_3,
            12
        );
        assert!(
            coin::balance<AptosCoin>(aptos_friend::get_vault_addr()) == share_cost_1 + share_cost_2 - share_cost_3,
            12
        );
        assert!(
            coin::balance<AptosCoin>(@aptos_friend_addr) == protocol_fee_1 + protocol_fee_2 + protocol_fee_3,
            12
        );

        {
            let (_, _, total_issued_shares) = aptos_friend::get_issuer(issuer_1_obj);
            let holder_holdings = aptos_friend::get_issuer_holder_holdings(issuer_1_obj);
            assert!(total_issued_shares == 13, 13);
            assert!(vector::length(&holder_holdings) == 2, 13);
            assert!(
                vector::borrow(&holder_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_1_addr),
                13
            );
            assert!(
                vector::borrow(&holder_holdings, 1) == &aptos_friend::get_holding_obj(user_1_addr, user_2_addr),
                13
            );
        };

        {
            let user_1_obj = aptos_friend::get_user_obj(user_1_addr);
            let user_1_holdings = aptos_friend::get_user_holdings(user_1_obj);
            assert!(vector::length(&user_1_holdings) == 1, 14);
            assert!(
                vector::borrow(&user_1_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_1_addr),
                14
            );

            let user_2_obj = aptos_friend::get_user_obj(user_2_addr);
            let user_2_holdings = aptos_friend::get_user_holdings(user_2_obj);
            assert!(vector::length(&user_2_holdings) == 1, 14);
            assert!(
                vector::borrow(&user_2_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_2_addr),
                14
            );
        };

        {
            let holding_obj = aptos_friend::get_holding_obj(user_1_addr, user_1_addr);
            let (_, _, shares) = aptos_friend::get_holding(holding_obj);
            assert!(shares == 8, 15);
        };

        // ================================= User 2 sell all user 1's share it owns ================================== //

        let (share_cost_4, issuer_fee_4, protocol_fee_4, total_cost_4) = aptos_friend::calculate_sell_share_cost(
            issuer_1_obj,
            5
        );
        let coins = coin::mint(total_cost_4, &mint_cap);
        coin::deposit(user_2_addr, coins);

        aptos_friend::sell_share(user_2, issuer_1_obj, 5);
        assert!(coin::balance<AptosCoin>(user_2_addr) == share_cost_4, 16);
        assert!(
            coin::balance<AptosCoin>(
                user_1_addr
            ) == issuer_fee_1 + issuer_fee_2 + issuer_fee_3 + issuer_fee_4 + share_cost_3,
            16
        );
        assert!(
            coin::balance<AptosCoin>(
                aptos_friend::get_vault_addr()
            ) == share_cost_1 + share_cost_2 - share_cost_3 - share_cost_4,
            16
        );
        assert!(
            coin::balance<AptosCoin>(
                @aptos_friend_addr
            ) == protocol_fee_1 + protocol_fee_2 + protocol_fee_3 + protocol_fee_4,
            16
        );

        {
            let (_, _, total_issued_shares) = aptos_friend::get_issuer(issuer_1_obj);
            let holder_holdings = aptos_friend::get_issuer_holder_holdings(issuer_1_obj);
            assert!(total_issued_shares == 8, 17);
            assert!(vector::length(&holder_holdings) == 1, 17);
            assert!(
                vector::borrow(&holder_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_1_addr),
                17
            );
        };

        {
            let user_1_obj = aptos_friend::get_user_obj(user_1_addr);
            let user_1_holdings = aptos_friend::get_user_holdings(user_1_obj);
            assert!(vector::length(&user_1_holdings) == 1, 18);
            assert!(
                vector::borrow(&user_1_holdings, 0) == &aptos_friend::get_holding_obj(user_1_addr, user_1_addr),
                18
            );

            let user_2_obj = aptos_friend::get_user_obj(user_2_addr);
            let user_2_holdings = aptos_friend::get_user_holdings(user_2_obj);
            assert!(vector::length(&user_2_holdings) == 0, 18);
        };

        // ================================= Clean up ================================== //

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }

    #[test(aptos_framework = @aptos_framework, deployer = @aptos_friend_addr, user_1 = @0x998)]
    fun buy_sell_should_have_same_price_when_supply_is_not_changed(
        aptos_framework: &signer,
        deployer: &signer,
        user_1: &signer,
    ) {
        // ================================= Setup ================================== //

        let user_1_addr = signer::address_of(user_1);

        let (burn_cap, mint_cap) = aptos_friend::init_module_for_test(aptos_framework, deployer);

        account::create_account_for_test(user_1_addr);
        coin::register<AptosCoin>(user_1);

        aptos_friend::issue_share(user_1, string::utf8(b"test_user_1"));
        let issuer_1_obj = aptos_friend::get_issuer_obj(user_1_addr);

        let (share_cost_1, _, _, total_cost_1) = aptos_friend::calculate_buy_share_cost(issuer_1_obj, 5);
        let coins = coin::mint(total_cost_1, &mint_cap);
        coin::deposit(user_1_addr, coins);
        aptos_friend::buy_share(user_1, issuer_1_obj, 5);
        let (share_cost_2, _, _, _) = aptos_friend::calculate_sell_share_cost(issuer_1_obj, 5);
        assert!(share_cost_1 == share_cost_2, 1);

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }
}
