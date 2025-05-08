module hyperion_interface_addr::position_v3 {

    use aptos_framework::fungible_asset::{Metadata};
    use aptos_framework::object::{Object};

    use hyperion_interface_addr::rewarder::PositionReward;
    use hyperion_interface_addr::i32::{Self, I32};

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Info has key {
        // whether inited after migration
        initialized: bool,
        // the amount of liquidity owned by this position
        liquidity: u128,
        tick_lower: I32,
        tick_upper: I32,
        // fee growth per unit of liquidity as of the last update to liquidity or fees owed
        fee_growth_inside_a_last: u128,
        fee_growth_inside_b_last: u128,
        // the fees owed to the position owner in token0/token1
        fee_owed_a: u64,
        fee_owed_b: u64,
        token_a: Object<Metadata>,
        token_b: Object<Metadata>,
        fee_tier: u8,
        rewards: vector<PositionReward>
    }

    #[event]
    struct CreatePositionEvent has store, drop {
        object_id: address,
        pool_id: address,
        token_a: Object<Metadata>,
        token_b: Object<Metadata>,
        fee_tier: u8,
        tick_lower: I32,
        tick_upper: I32
    }

    const ENOT_POSITION_OWNER: u64 = 1200001;
    const EPOSITION_NOT_INITIALIZED: u64 = 1200002;
    const EPOSITION_NOT_EMPTY: u64 = 12000003;

    public fun get_tick(_position: Object<Info>): (I32, I32) {
        (i32::zero(), i32::zero())
    }

    public fun get_liquidity(_position: Object<Info>): u128 {
        0
    }
}
