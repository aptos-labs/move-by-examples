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
            // replace the pool address with the actual address after creating it on thala
            // object::address_to_object(
            //     @0xda2702d16f9c3b62fe0d07f63af49f05b6237c9abec956f9cbb8a11296f2450a
            // )
            object::address_to_object(
                @0x64741bf5630a02b92c9fd582bf0e0e0fb096cd9026916c1056354d3a4f9edfa6
            )
        );
    }
}
