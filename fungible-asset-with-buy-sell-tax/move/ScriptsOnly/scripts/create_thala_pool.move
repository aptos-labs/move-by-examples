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
                // APT in FA format
                object::address_to_object(@0xa),
                // replace the FA address with your the FA you created
                // You can look it up in the explorer
                object::address_to_object(
                    @0x654109e8d80ee16b6d6bb67657cbb053a826251a828e4644f1ba5f22f7d7a19b
                )
            ],
            vector[100_000, 10_000_000],
            vector[50, 50],
            100
        );
    }
}
