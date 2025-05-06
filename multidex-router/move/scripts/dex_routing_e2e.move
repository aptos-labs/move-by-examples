script { 
    use std::signer;
    use std::debug;
    use std::string::{String, utf8, append};
    use std::string_utils;
    use aptos_framework::coin;
    use liquidswap::router_v2;
    use liquidswap::curves::Uncorrelated;
    use liquidswap_lp::lp_coin::LP;
    use pancake::router;
    use multidex_router_addr::artificial_coins::{Self, AT, BT};
    use multidex_router_addr::multidex_router;

    // Errors:
    const ECOIN_AT_MINTED_AMOUNT_MISMATCH: u64 = 1;
    const ECOIN_BT_MINTED_AMOUNT_MISMATCH: u64 = 2;
    const ECOIN_AT_BEGAN_AMOUNT_MISMATCH: u64 = 11;
    const ECOIN_BT_BEGAN_AMOUNT_MISMATCH: u64 = 12;
    const ECOIN_AT_LIQUIDSWAP_AMOUNT_MISMATCH: u64 = 21;
    const ECOIN_BT_LIQUIDSWAP_AMOUNT_MISMATCH: u64 = 22;


    fun test_liquid_to_pancake_routing(account: &signer){
        // ! Deploy Artificial Coins and Multidex Router modules, beforehand.
        // Register and Mint tokens.
        let account_addr = signer::address_of(account);
        let a_amount: u64 = 10_000_000;
        let b_amount: u64 = 50_000_000;
        artificial_coins::register_coins(account);
        aptos_framework::managed_coin::register<AT>(account);
        aptos_framework::managed_coin::register<BT>(account);
        artificial_coins::mint_coin<AT>(account, account_addr, a_amount);
        artificial_coins::mint_coin<BT>(account, account_addr, b_amount);
        assert!(coin::balance<AT>(account_addr) == 10_000_000, ECOIN_AT_MINTED_AMOUNT_MISMATCH);
        assert!(coin::balance<BT>(account_addr) == 50_000_000, ECOIN_BT_MINTED_AMOUNT_MISMATCH);

        // Create Pool of tokens AT/BT on liquidswap and add liquidity.
        router_v2::register_pool<AT, BT, Uncorrelated>(account);
        let (min_at_coin_liq, min_bt_coin_liq) = router_v2::calc_optimal_coin_values<AT, BT, Uncorrelated>(
            1_000_000,
            5_000_000,
            1,
            1
        );
        let at_coin_liq = coin::withdraw<AT>(account, min_at_coin_liq);
        let bt_coin_liq = coin::withdraw<BT>(account, min_bt_coin_liq);
        let (at_coin_remainder, bt_coin_remainder, lp) = router_v2::add_liquidity<AT, BT, Uncorrelated>(
            at_coin_liq,
            min_at_coin_liq,
            bt_coin_liq,
            min_bt_coin_liq
        );
        coin::deposit(account_addr, at_coin_remainder);
        coin::deposit(account_addr, bt_coin_remainder);
        coin::register<LP<AT, BT, Uncorrelated>>(account);
        coin::deposit(account_addr, lp);
        // Create Pool of tokens AT/BT on pancakeswap and add liquidity.
        router::add_liquidity<AT, BT>(
            account, 
            5_000_000, 
            5_000_000, 
            1, 
            1
        );

        // Perform 2 swaps through our multidex_router Module.
        // * AT --Liquidswap--> BT --PancakeSwap--> AT
        let account_addr = signer::address_of(account);
        let at_amountIn: u64 = 1000;
        let at_balance_pre_route = coin::balance<AT>(account_addr);
        let bt_balance_pre_route = coin::balance<BT>(account_addr);
        assert!(at_balance_pre_route == 4000000, ECOIN_AT_BEGAN_AMOUNT_MISMATCH);
        assert!(bt_balance_pre_route == 40000000, ECOIN_BT_BEGAN_AMOUNT_MISMATCH);
        multidex_router::liquid_to_pancake_route<AT, BT, Uncorrelated>(account, at_amountIn); // * AT -Liquidswap-> BT -PancakeSwap-> AT
        let at_balance_post_route = coin::balance<AT>(account_addr);
        let bt_balance_post_route = coin::balance<BT>(account_addr);

        // Debug Logs.
        let debug_routing_string: String = utf8(b"\n\n-----Pre-Routing----");
        append(&mut debug_routing_string, utf8(b"\nAT Balance: "));
        append(&mut debug_routing_string, string_utils::to_string(&at_balance_pre_route));
        append(&mut debug_routing_string, utf8(b"\nBT Balance: "));
        append(&mut debug_routing_string, string_utils::to_string(&bt_balance_pre_route));
        append(&mut debug_routing_string, utf8(b"\n\n"));
        append(&mut debug_routing_string, utf8(b"\n\n-----Post-Routing----"));
        append(&mut debug_routing_string, utf8(b"\nAT Balance: "));
        append(&mut debug_routing_string, string_utils::to_string(&at_balance_post_route));
        append(&mut debug_routing_string, utf8(b"\nBT Balance: "));
        append(&mut debug_routing_string, string_utils::to_string(&bt_balance_post_route));
        append(&mut debug_routing_string, utf8(b"\n\n"));
        debug::print(&debug_routing_string);
    }
}