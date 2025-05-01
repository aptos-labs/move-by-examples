script {
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::object;

    use thala_swap_v2_interface_addr::coin_wrapper::{Self, Notacoin};

    // This Move script runs atomically
    // Move script is how we batch multiple function calls in 1 tx
    // Similar to Solana allows multiple instructions in 1 tx
    fun create_thala_pool(sender: &signer) {
        coin_wrapper::create_pool_weighted<AptosCoin, Notacoin, Notacoin, Notacoin>(
            sender,
            vector[
                object::address_to_object(@0xa),
                object::address_to_object(
                    @0x29a5b5c54af3ad35ee0206113e938f4a73fc8b4ca945e83cea7627d249f8028a
                )
            ],
            vector[100_000, 5_000_000],
            vector[40, 60],
            100
        );
    }
}
