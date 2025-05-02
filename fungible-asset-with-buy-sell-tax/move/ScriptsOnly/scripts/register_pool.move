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
                @0xad0d4b5935d16de9e312930fbd7be9cb39ec7ac602faea000dd928f6e72bd464
            )
        );
    }
}
