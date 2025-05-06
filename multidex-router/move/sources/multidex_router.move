module multidex_router_addr::multidex_router {
    use std::signer;
    use aptos_framework::coin::{Self, Coin};
    use liquidswap::router_v2;
    use pancake::router;


    // ================================= Entry Functions ================================= //

    // ** 
    // * PrimaryToken - AT/BT/<other>
    // * IntermediaryToken - AT/BT/<other>
    // * Route: [PrimaryToken --Liquidswap--> IntermediaryToken --PancakeSwap--> PrimaryToken]
    public entry fun liquid_to_pancake_route<PrimaryToken, IntermediaryToken, Curve>(account: &signer, amountIn: u64) {
        let coins_to_swap: Coin<PrimaryToken> = coin::withdraw<PrimaryToken>(account, amountIn);        
        let remaining_coins_count = liquidswap_swap<PrimaryToken, IntermediaryToken, Curve>(account, amountIn, coins_to_swap);
        _ = pancakeswap_swap<IntermediaryToken, PrimaryToken>(account, remaining_coins_count);
    }

    // ** 
    // * PrimaryToken - AT/BT/<other>
    // * IntermediaryToken - AT/BT/<other>
    // * Route: [PrimaryToken --PancakeSwap--> IntermediaryToken --Liquidswap--> PrimaryToken]
    public entry fun pancake_to_liquid_route<PrimaryToken, IntermediaryToken, Curve>(account: &signer, amountIn: u64) {
        let coins_to_swap: Coin<PrimaryToken> = coin::withdraw<PrimaryToken>(account, amountIn);        
        let remaining_coins_count = pancakeswap_swap<IntermediaryToken, PrimaryToken>(account, amountIn);
        _ = liquidswap_swap<PrimaryToken, IntermediaryToken, Curve>(account, remaining_coins_count, coins_to_swap);
    }


    // ================================= Internal Functions ================================= //

    fun liquidswap_swap<PrimaryToken, IntermediaryToken, Curve>(account: &signer, amountIn: u64, coins_to_swap: Coin<PrimaryToken>): u64  {
        let coins_to_receive = router_v2::get_amount_out<PrimaryToken, IntermediaryToken, Curve>(amountIn);
        let coins = router_v2::swap_exact_coin_for_coin<PrimaryToken, IntermediaryToken, Curve>(coins_to_swap,coins_to_receive);
        let account_addr = signer::address_of(account);
        // Register generic coin iff account hasn't already.
        if (!coin::is_account_registered<IntermediaryToken>(account_addr)) {
            coin::register<IntermediaryToken>(account);
        };
        coin::deposit(account_addr, coins);

        coins_to_receive
    }

    fun pancakeswap_swap<PrimaryToken, IntermediaryToken>(account: &signer, amountIn: u64): u64  {
        let account_addr = signer::address_of(account);
        let before_balance: u64 = coin::balance<IntermediaryToken>(account_addr);
        router::swap_exact_input<PrimaryToken, IntermediaryToken>(account, amountIn, 0);
        let after_balance: u64 = coin::balance<IntermediaryToken>(account_addr);

        (after_balance - before_balance)
    }
}
