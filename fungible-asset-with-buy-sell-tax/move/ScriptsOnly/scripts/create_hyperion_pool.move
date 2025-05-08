script {
    use aptos_framework::object;

    use hyperion_interface_addr::router_v3;

    // This Move script runs atomically
    // Move script is how we batch multiple function calls in 1 tx
    // Similar to Solana allows multiple instructions in 1 tx
    fun create_hyperion_pool(sender: &signer) {
        router_v3::create_liquidity(
            sender,
            object::address_to_object(@0xa),
            object::address_to_object(
                @0x654109e8d80ee16b6d6bb67657cbb053a826251a828e4644f1ba5f22f7d7a19b
            ),
            3,
            4294523660,
            443636,
            46054,
            100_000,
            9_999_888,
            99_000,
            9_899_889,
            4902356635
        )
    }
}
