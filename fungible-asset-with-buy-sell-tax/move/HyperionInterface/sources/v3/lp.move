module hyperion_interface_addr::lp {

    use aptos_framework::object::{Self, Object, ExtendRef};
    use aptos_framework::fungible_asset::{BurnRef, MintRef, TransferRef, Metadata};

    const LP_TOKEN_DECIMALS: u8 = 8;

    const ELP_NOT_EMPTY: u64 = 1300001;

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct LPTokenRefs has key, store {
        burn_ref: BurnRef,
        mint_ref: MintRef,
        transfer_ref: TransferRef,
        extend_ref: ExtendRef
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct LPObjectRef has key, drop {
        token_a: Object<Metadata>,
        token_b: Object<Metadata>,
        fee_tier: u8,
        lp_amount: u64,
        transfer_ref: object::TransferRef,
        delete_ref: object::DeleteRef,
        extend_ref: object::ExtendRef
    }
}
