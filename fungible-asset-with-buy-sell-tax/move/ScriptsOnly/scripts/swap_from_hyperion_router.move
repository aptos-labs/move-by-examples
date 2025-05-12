script {
    use aptos_framework::object;
    use aptos_framework::signer;

    use hyperion_interface_addr::router_v3;

    // This Move script runs atomically
    // Move script is how we batch multiple function calls in 1 tx
    // Similar to Solana allows multiple instructions in 1 tx
    fun swap_from_hyperion_router(sender: &signer) {
        router_v3::exact_input_swap_entry(
            sender,
            3,
            500_000,
            0,
            // sqrt_price_limit: a x64 fixed-point number, indicate price impact limit after swap
            // for this demo, we just set it to arbitrary big
            10_000_000_000_000_000_000_000_000,
            object::address_to_object(
                // replace with your own FA address
                @0xdb1c59ba6f4aef11bc6dfc15f5eb9a168b04656986a7aeb7976abcee8b1d62dc
            ),
            object::address_to_object(@0xa),
            signer::address_of(sender),
            0,
        );
    }
}
