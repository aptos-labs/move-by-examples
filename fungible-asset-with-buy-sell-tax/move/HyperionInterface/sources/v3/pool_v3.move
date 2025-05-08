module hyperion_interface_addr::pool_v3 {
    use std::vector;
    use std::string::{String};
    use std::option::{Self, Option};
    use aptos_std::smart_table::SmartTable;
    use aptos_std::smart_vector::{SmartVector};
    use aptos_framework::object::{Self, Object};
    use aptos_framework::fungible_asset::{Self, Metadata, FungibleStore, FungibleAsset};

    use hyperion_interface_addr::tick_bitmap::{BitMap};
    use hyperion_interface_addr::i32::{I32};
    use hyperion_interface_addr::tick::{TickInfo};
    use hyperion_interface_addr::lp::{LPTokenRefs};
    use hyperion_interface_addr::position_v3;
    use hyperion_interface_addr::position_blacklist::{PositionBlackList};
    use hyperion_interface_addr::rewarder::{Self, RewarderManager, RewardRate, Rewarder};

    struct LiquidityPoolConfigsV3 has key {
        all_pools: SmartVector<Object<LiquidityPoolV3>>,
        is_paused: bool,
        fee_manager: address,
        pauser: address,
        pending_fee_manager: address,
        pending_pauser: address,
        tick_spacing_list: vector<u64>
    }

    struct LiquidityPoolInfoV3 has drop, copy {
        pool: Object<LiquidityPoolV3>,
        token_a: Object<Metadata>,
        token_b: Object<Metadata>,
        fee_rate: u64,
        token_a_reserve: u64,
        token_b_reserve: u64,
        liquidity_total: u128
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct LiquidityPoolV3 has key {
        token_a_liquidity: Object<FungibleStore>,
        token_b_liquidity: Object<FungibleStore>,
        token_a_fee: Object<FungibleStore>,
        token_b_fee: Object<FungibleStore>,
        // the current price
        sqrt_price: u128,
        // liquidity current tick
        liquidity: u128,
        // the current tick
        tick: I32,
        // the most-recently updated index of the observations array
        observation_index: u64,
        // the current maximum number of observations that are being stored
        observation_cardinality: u64,
        // the next maximum number of observations to store, triggered in observations.write
        observation_cardinality_next: u64,
        /// The numerator of fee rate, the denominator is 1_000_000.
        fee_rate: u64,
        // the current protocol fee as a percentage of the swap fee taken on withdrawal
        // the denominator is 1_000_000.
        fee_protocol: u64,
        // whether the pool is locked
        unlocked: bool,
        fee_growth_global_a: u128,
        fee_growth_global_b: u128,
        seconds_per_liquidity_oracle: u128,
        seconds_per_liquidity_incentive: u128,
        position_blacklist: PositionBlackList,
        last_update_timestamp: u64,
        tick_info: SmartTable<I32, TickInfo>,
        tick_map: BitMap,
        tick_spacing: u32,
        protocol_fees: ProtocolFees,
        lp_token_refs: LPTokenRefs,
        max_liquidity_per_tick: u128,
        rewarder_manager: RewarderManager
    }

    struct ProtocolFees has store {
        token_a: Object<FungibleStore>,
        token_b: Object<FungibleStore>
    }

    #[event]
    /// Event emitted when a pool is created.
    struct CreatePoolEvent has drop, store {
        pool: Object<LiquidityPoolV3>,
        token_a: Object<Metadata>,
        token_b: Object<Metadata>,
        fee_rate: u64,
        fee_tier: u8,
        sqrt_price: u128,
        tick: I32
    }

    #[event]
    struct AddLiquidityEvent has store, drop {
        pool_id: address,
        object_id: address,
        token_a: Object<Metadata>,
        token_b: Object<Metadata>,
        fee_tier: u8,
        is_delete: bool,
        added_lp_amount: u128,
        previous_liquidity_amount: u128,
        amount_a: u64,
        amount_b: u64
    }

    #[event]
    struct RemoveLiquidityEvent has store, drop {
        pool_id: address,
        object_id: address,
        token_a: Object<Metadata>,
        token_b: Object<Metadata>,
        fee_tier: u8,
        is_delete: bool,
        burned_lp_amount: u128,
        previous_liquidity_amount: u128,
        amount_a: u64,
        amount_b: u64
    }

    #[event]
    /// Event emitted when a swap happens.
    struct SwapEvent has drop, store {
        pool_id: address,
        from_token: Object<Metadata>,
        to_token: Object<Metadata>,
        amount_in: u64,
        amount_out: u64,
        fee_amount: u64,
        protocol_fee_amount: u64
    }

    #[event]
    struct ClaimFeesEvent has drop, store {
        pool: Object<LiquidityPoolV3>,
        lp_object: Object<position_v3::Info>,
        token: Object<Metadata>,
        amount: u64,
        owner: address
    }

    #[event]
    struct SwapBeforeEvent has drop, store {
        pool_id: address,
        tick: I32,
        sqrt_price: u128,
        liquidity: u128
    }

    #[event]
    struct SwapAfterEvent has drop, store {
        pool_id: address,
        tick: I32,
        sqrt_price: u128,
        liquidity: u128
    }

    #[event]
    struct PoolSnapshot has drop, store {
        pool_id: address,
        sqrt_price: u128,
        liquidity: u128,
        tick: I32,
        // the most-recently updated index of the observations array
        observation_index: u64,
        // the current maximum number of observations that are being stored
        observation_cardinality: u64,
        // the next maximum number of observations to store, triggered in observations.write
        observation_cardinality_next: u64,
        fee_rate: u64,
        fee_rate_denominatore: u64,
        fee_growth_global_a: u128,
        fee_growth_global_b: u128,
        tick_spacing: u32
    }

    const Q64: u128 = 0x10000000000000000;
    const FEE_RATE_DENOMINATOR: u64 = 1000000;
    const TICK_SPACING_VEC: vector<u32> = vector[1, 10, 60, 200];
    const FEE_RATE_VEC: vector<u64> = vector[100, 500, 3000, 10000];

    const ETICK_NOT_EXSIT: u64 = 100001;
    const ESWAP_AMOUNT_INVALID: u64 = 100002;
    const EPOOL_LOCKED: u64 = 100003;
    const ESQRT_PRICE_LIMIT_UNAVAILABLE: u64 = 100004;
    const ELIQUIDITY_DELTA_INVALID: u64 = 100005;
    const EAMOUNT_A_INPUT_LESS: u64 = 100006;
    const EAMOUNT_B_INPUT_LESS: u64 = 100007;
    const ENOT_POSITION_OWNER: u64 = 100008;
    const ESWAP_ERROR: u64 = 100009;
    const EOFFSET_OUT_OF_BOUNDS: u64 = 100010;
    const EPOOL_NOT_EXISTS: u64 = 100011;
    const EPOSITION_BLOKED: u64 = 100012;

    #[view]
    public fun pool_reserve_amount(_pool_id: Object<LiquidityPoolV3>): (u64, u64) {
        (0, 0)
    }

    #[view]
    public fun pool_rewarder_list(_pool_id: Object<LiquidityPoolV3>): vector<Rewarder> {
        vector::empty<Rewarder>()
    }

    #[view]
    public fun liquidity_pool_exists(
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8
    ): bool {
        false
    }

    #[view]
    public fun liquidity_pool(
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8
    ): Object<LiquidityPoolV3> {
        object::address_to_object<LiquidityPoolV3>(@0x0)
    }

    #[view]
    public fun liquidity_pool_address_safe(
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8
    ): (bool, address) {
        (false, @0x0)
    }

    #[view]
    public fun liquidity_pool_address(
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8
    ): address {
        @0x0
    }

    #[view]
    public fun current_tick_and_price(_pool_address: address): (u32, u128) {
        (0, 0)
    }

    #[view]
    public fun current_price(
        _token_a: Object<Metadata>, _token_b: Object<Metadata>, _fee_tier: u8
    ): u128 {
        0
    }

    // need adapt to all of standards combination
    public fun create_pool(
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8,
        _tick: u32
    ): Object<LiquidityPoolV3> {
        object::address_to_object<LiquidityPoolV3>(@0x0)
    }

    public fun open_position(
        _user: &signer,
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8,
        _tick_lower: u32,
        _tick_upper: u32
    ): Object<position_v3::Info> {
        object::address_to_object<position_v3::Info>(@0x0)
    }

    public fun add_liquidity(
        _user: &signer,
        _position: Object<position_v3::Info>,
        _liquidity_delta: u128,
        _fa_a: FungibleAsset,
        _fa_b: FungibleAsset
    ): (u64, u64, FungibleAsset, FungibleAsset) {
        (0, 0, _fa_a, _fa_b)
    }

    public fun claim_fees(
        _user: &signer, _position: Object<position_v3::Info>
    ): (FungibleAsset, FungibleAsset) {
        (
            fungible_asset::zero<Metadata>(object::address_to_object(@0xa)),
            fungible_asset::zero<Metadata>(object::address_to_object(@0xa))
        )

    }

    public fun remove_liquidity(
        _user: &signer, _position: Object<position_v3::Info>, _liquidity_delta: u128
    ): (Option<FungibleAsset>, Option<FungibleAsset>) {
        (option::none<FungibleAsset>(), option::none<FungibleAsset>())
    }

    public fun claim_rewards(
        _user: &signer, _position: Object<position_v3::Info>
    ): vector<FungibleAsset> {
        vector::empty<FungibleAsset>()
    }

    public fun swap(
        _pool: Object<LiquidityPoolV3>,
        _a2b: bool,
        _by_amount_in: bool,
        _amount: u64,
        _fa_in: FungibleAsset,
        _sqrt_price_limit: u128
    ): (u64, FungibleAsset, FungibleAsset) {
        (0, _fa_in, fungible_asset::zero<Metadata>(object::address_to_object(@0xa)))
    }

    /////////////////////////////////////  view  /////////////////////////////////////
    #[view]
    public fun get_fee_rate(_fee_tier: u8): u64 {
        0
    }

    #[view]
    public fun liquidity_pool_info(_pool: Object<LiquidityPoolV3>): vector<String> {
        vector::empty<String>()
    }

    #[view]
    public fun liquidity_pool_info_both_coin<CoinTypeA, CoinTypeB>(
        _fee_tier: u8
    ): vector<String> {
        vector::empty<String>()
    }

    #[view]
    public fun liquidity_pool_info_with_coin_fa<CoinType>(
        _token: Object<Metadata>, _fee_tier: u8
    ): vector<String> {
        vector::empty<String>()
    }

    #[view]
    public fun liquidity_pool_info_both_fa(
        _token_a: Object<Metadata>, _token_b: Object<Metadata>, _fee_tier: u8
    ): vector<String> {
        vector::empty<String>()
    }

    #[view]
    public fun get_amount_in(
        _pool: Object<LiquidityPoolV3>,
        _from: Object<Metadata>,
        _amount: u64
    ): (u64, u64) {
        (0, 0)
    }

    #[view]
    public fun get_amount_out(
        _pool: Object<LiquidityPoolV3>,
        _from: Object<Metadata>,
        _amount: u64
    ): (u64, u64) {
        (0, 0)
    }

    #[view]
    public fun all_pools(): vector<Object<LiquidityPoolV3>> {
        vector::empty<Object<LiquidityPoolV3>>()
    }

    #[view]
    public fun get_pending_fees(_position: Object<position_v3::Info>): vector<u64> {
        vector::empty<u64>()
    }

    #[view]
    public fun get_position_emission_rate(
        _position: Object<position_v3::Info>
    ): vector<RewardRate> {
        vector::empty<RewardRate>()
    }

    #[view]
    public fun get_pending_rewards(
        _position: Object<position_v3::Info>
    ): vector<rewarder::PendingReward> {
        vector::empty<rewarder::PendingReward>()
    }

    #[view]
    public fun supported_inner_assets(_pool: Object<LiquidityPoolV3>):
        vector<Object<Metadata>> {
        vector::empty<Object<Metadata>>()
    }

    #[view]
    public fun get_pool_liquidity(_pool: Object<LiquidityPoolV3>): u128 {
        0
    }
}
