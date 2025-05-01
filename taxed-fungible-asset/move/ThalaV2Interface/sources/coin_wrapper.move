module thala_swap_v2_interface_addr::coin_wrapper {
    use aptos_framework::fungible_asset::FungibleStore;
    use aptos_framework::object::Object;

    struct Notacoin {}

    public entry fun create_pool_weighted<T1, T2, T3, T4>(
        sender: &signer,
        fa_metadatas: vector<Object<FungibleStore>>,
        seed_amounts: vector<u64>,
        weights: vector<u64>,
        arg4: u64,
    ) {
        abort 0;
    }
}
