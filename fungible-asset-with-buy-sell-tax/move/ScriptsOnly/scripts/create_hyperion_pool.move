script {
    use aptos_framework::object;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::primary_fungible_store;
    use aptos_framework::signer;

    use hyperion_interface_addr::router_v3;

    // This Move script runs atomically
    // Move script is how we batch multiple function calls in 1 tx
    // Similar to Solana allows multiple instructions in 1 tx
    fun create_hyperion_pool(sender: &signer) {

        let initial_tfa_liquidity = 5_000_000;
        let initial_apt_liquidity = 1_000;

        // convert coin APT to FA APT for simplicity
        let coin_apt = coin::withdraw<AptosCoin>(sender, initial_apt_liquidity);
        let fa_apt = coin::coin_to_fungible_asset<AptosCoin>(coin_apt);
        primary_fungible_store::deposit(signer::address_of(sender), fa_apt);

        router_v3::create_liquidity(
            sender,
            object::address_to_object(@0xa),
            object::address_to_object(
                // replace with your own FA address
                @0xdb1c59ba6f4aef11bc6dfc15f5eb9a168b04656986a7aeb7976abcee8b1d62dc
            ),
            /*
            const FEE_RATE_VEC: vector<u64> = vector[100, 500, 3000, 10000, 1000], this is the value in contract
            corresponding to [0.01%, 0.05%, 0.3%, 1%, 0.1%] fee rate list, and fee_tier is the index of the array.
            */
            3,
            /*
            const TICK_SPACING_VEC: vector<u32> = vector[1, 10, 60, 200, 20, 50];
            tick needs to be divisible by tick_spacing, and the value in contract is 1, 10, 60, 200, 20, 50
            corresponding to [0.01%, 0.05%, 0.3%, 1%, 0.1%] fee rate list.
            */
            1_000,
            10_000,
            5_000,
            initial_apt_liquidity,
            initial_tfa_liquidity,
            0,
            0,
            // not used
            0
        )
    }
}
