script {
    use aptos_framework::object;

    use thala_swap_v2_router_interface_addr::router::{Self, Notacoin};

    // This Move script runs atomically
    // Move script is how we batch multiple function calls in 1 tx
    // Similar to Solana allows multiple instructions in 1 tx
    fun swap_from_router(sender: &signer) {
        router::swap_exact_in_router_entry<Notacoin>(
            sender,
            vector[
                object::address_to_object(
                    @0x894d69ead4d27ffed3800c2c1e78737078fb0ac6e6970a9439993d34bf2c890a
                )
            ],
            vector[object::address_to_object(@0xa)],
            1_000_000,
            object::address_to_object(
                @0x86e1c544e66c6efee4b300440d08aaf38b1e31fd1f6493757c2b8629ec1ffbd1
            ),
            1
        );
    }
}
