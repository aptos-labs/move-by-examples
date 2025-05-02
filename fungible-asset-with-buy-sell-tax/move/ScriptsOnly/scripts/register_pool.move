script {
    use aptos_framework::object;

    use taxed_fa_addr::taxed_fa;

    // This Move script runs atomically
    // Move script is how we batch multiple function calls in 1 tx
    // Similar to Solana allows multiple instructions in 1 tx
    fun register_pool(sender: &signer) {
        // replace the pool address with the actual address after creating it on thala
        taxed_fa::register_pool(
            sender,
            object::address_to_object(
                @0x894d69ead4d27ffed3800c2c1e78737078fb0ac6e6970a9439993d34bf2c890a
            )
        );
    }
}
