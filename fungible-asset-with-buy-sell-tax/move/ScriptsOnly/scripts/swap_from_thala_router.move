script {
    use aptos_framework::object;

    use thala_swap_v2_router_interface_addr::router::{Self, Notacoin};

    // This Move script runs atomically
    // Move script is how we batch multiple function calls in 1 tx
    // Similar to Solana allows multiple instructions in 1 tx
    fun swap_from_thala_router(sender: &signer) {
        router::swap_exact_in_router_entry<Notacoin>(
            sender,
            vector[
                // replace this with your pool address
                object::address_to_object(
                    @0xda2702d16f9c3b62fe0d07f63af49f05b6237c9abec956f9cbb8a11296f2450a
                )
            ],
            vector[object::address_to_object(@0xa)],
            1_000_000,
            object::address_to_object(
                // replace this with your FA address
                @0x654109e8d80ee16b6d6bb67657cbb053a826251a828e4644f1ba5f22f7d7a19b
            ),
            1
        );
    }
}
