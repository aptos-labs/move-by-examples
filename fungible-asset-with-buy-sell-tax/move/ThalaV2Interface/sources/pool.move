module thala_swap_v2_interface_addr::pool {
    use aptos_framework::fungible_asset::{Metadata, MintRef, TransferRef, BurnRef};
    use aptos_framework::object::{Object, ExtendRef};

    struct Pool has key {
        extend_ref: ExtendRef,
        assets_metadata: vector<Object<Metadata>>,
        pool_type: u8,
        swap_fee_bps: u64,
        locked: bool,
        lp_token_mint_ref: MintRef,
        lp_token_transfer_ref: TransferRef,
        lp_token_burn_ref: BurnRef
    }
}
