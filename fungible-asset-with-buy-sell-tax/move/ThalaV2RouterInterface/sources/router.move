module thala_swap_v2_router_interface_addr::router {
    use aptos_framework::fungible_asset::Metadata;
    use aptos_framework::object::Object;

    use thala_swap_v2_interface_addr::pool::Pool;

    struct Notacoin {}

    public entry fun swap_exact_in_router_entry<T>(
        sender: &signer,
        pools: vector<Object<Pool>>,
        arg2: vector<Object<Metadata>>,
        from_amount: u64,
        from_fa: Object<Metadata>,
        min_received: u64
    ) {
        abort 0;
    }
}
