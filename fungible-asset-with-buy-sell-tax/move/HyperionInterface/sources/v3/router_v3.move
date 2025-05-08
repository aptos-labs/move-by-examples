module hyperion_interface_addr::router_v3 {

    use aptos_framework::object::{Object};
    use aptos_framework::fungible_asset::{Metadata};
    use hyperion_interface_addr::position_v3;

    const EAMOUNT_A_TOO_LESS: u64 = 200001;
    const EAMOUNT_B_TOO_LESS: u64 = 200002;
    const EAMOUNT_OUT_TOO_LESS: u64 = 200003;
    const EAMOUNT_IN_TOO_MUCH: u64 = 200004;
    const ELIQUIDITY_NOT_IN_CURRENT_REGION: u64 = 200005;
    const EMETADATA_NOT_MATCHED: u64 = 200006;
    const EOUT_TOKEN_NOT_MATCHED: u64 = 200007;
    const EOUT_AMOUNT_TOO_LESS: u64 = 200008;
    const EIN_TOKEN_NOT_MATCHED: u64 = 200009;

    /////////////////////////////////////////////////// PROTOCOL ///////////////////////////////////////////////////////
    public entry fun create_pool(
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8,
        _tick: u32
    ) {
        abort(0);
    }

    public entry fun create_pool_coin<CoinType>(
        _token_b: Object<Metadata>,
        _fee_tier: u8,
        _tick: u32
    ) {
        abort(0);
    }

    public entry fun create_pool_both_coins<CoinType1, CoinType2>(
        _fee_tier: u8, _tick: u32
    ) {
        abort(0);
    }

    public entry fun create_liquidity(
        _lp: &signer,
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8,
        _tick_lower: u32,
        _tick_upper: u32,
        _tick_current: u32,
        _amount_a_desired: u64,
        _amount_b_desired: u64,
        _amount_a_min: u64,
        _amount_b_min: u64,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun create_liquidity_coin<CoinType>(
        _lp: &signer,
        _token: Object<Metadata>,
        _fee_tier: u8,
        _tick_lower: u32,
        _tick_upper: u32,
        _tick_current: u32,
        _amount_a_desired: u64,
        _amount_b_desired: u64,
        _amount_a_min: u64,
        _amount_b_min: u64,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun create_liquidity_both_coins<CoinType1, CoinType2>(
        _lp: &signer,
        _fee_tier: u8,
        _tick_lower: u32,
        _tick_upper: u32,
        _tick_current: u32,
        _amount_a_desired: u64,
        _amount_b_desired: u64,
        _amount_a_min: u64,
        _amount_b_min: u64,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun open_position(
        _lp: &signer,
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8,
        _tick_lower: u32,
        _tick_upper: u32,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun open_position_coin<CoinType>(
        _lp: &signer,
        _token: Object<Metadata>,
        _fee_tier: u8,
        _tick_lower: u32,
        _tick_upper: u32,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun open_position_both_coins<CoinType1, CoinType2>(
        _lp: &signer,
        _fee_tier: u8,
        _tick_lower: u32,
        _tick_upper: u32,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun add_liquidity(
        _lp: &signer,
        _lp_object: Object<position_v3::Info>,
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8,
        _amount_a_desired: u64,
        _amount_b_desired: u64,
        _amount_a_min: u64,
        _amount_b_min: u64,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun add_liquidity_coin<CoinType>(
        _lp: &signer,
        _lp_object: Object<position_v3::Info>,
        _token: Object<Metadata>,
        _fee_tier: u8,
        _amount_a_desired: u64,
        _amount_b_desired: u64,
        _amount_a_min: u64,
        _amount_b_min: u64,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun add_liquidity_both_coins<CoinType1, CoinType2>(
        _lp: &signer,
        _lp_object: Object<position_v3::Info>,
        _fee_tier: u8,
        _amount_a_desired: u64,
        _amount_b_desired: u64,
        _amount_a_min: u64,
        _amount_b_min: u64,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun remove_liquidity(
        _lp: &signer,
        _lp_object: Object<position_v3::Info>,
        _liquidity_delta: u128,
        _amount_a_min: u64,
        _amount_b_min: u64,
        _recipient: address,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun remove_liquidity_coin<CoinType>(
        _lp: &signer,
        _lp_object: Object<position_v3::Info>,
        _liquidity_delta: u128,
        _amount_a_min: u64,
        _amount_b_min: u64,
        _recipient: address,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun remove_liquidity_both_coins<CoinType1, CoinType2>(
        _lp: &signer,
        _lp_object: Object<position_v3::Info>,
        _liquidity_delta: u128,
        _amount_a_min: u64,
        _amount_b_min: u64,
        _recipient: address,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun claim_fees(
        _lp: &signer, _lp_objects: vector<address>, _to: address
    ) {

        abort(0);
    }

    /////////////////////////////////////////////////// USERS /////////////////////////////////////////////////////////
    /// Swap an amount of fungible assets for another fungible asset. User can specifies the minimum amount they
    /// expect to receive. If the actual amount received is less than the minimum amount, the transaction will fail.
    public entry fun exact_input_swap_entry(
        _user: &signer,
        _fee_tier: u8,
        _amount_in: u64,
        _amount_out_min: u64,
        _sqrt_price_limit: u128,
        _from_token: Object<Metadata>,
        _to_token: Object<Metadata>,
        _recipient: address,
        _deadline: u64
    ) {
        abort(0);
    }

    /// Swap an amount of coins for fungible assets. User can specifies the minimum amount they expect to receive.
    public entry fun exact_input_coin_for_asset_entry<FromCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in: u64,
        _amount_out_min: u64,
        _sqrt_price_limit: u128,
        _to_token: Object<Metadata>,
        _recipient: address,
        _deadline: u64
    ) {
        abort(0);
    }

    /// Swap an amount of fungible assets for coins. User can specifies the minimum amount they expect to receive.
    public entry fun exact_input_asset_for_coin_entry<ToCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in: u64,
        _amount_out_min: u64,
        _sqrt_price_limit: u128,
        _from_token: Object<Metadata>,
        _recipient: address,
        _deadline: u64
    ) {
        abort(0);
    }

    /// Swap an amount of coins for another coin. User can specifies the minimum amount they expect to receive.
    public entry fun exact_input_coin_for_coin_entry<FromCoin, ToCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in: u64,
        _amount_out_min: u64,
        _sqrt_price_limit: u128,
        _recipient: address,
        _deadline: u64
    ) {
        abort(0);
    }

    public entry fun exact_output_swap_entry(
        _user: &signer,
        _fee_tier: u8,
        _amount_in_max: u64,
        _amount_out: u64,
        _sqrt_price_limit: u128,
        _from_token: Object<Metadata>,
        _to_token: Object<Metadata>,
        _recipient: address,
        _deadline: u64
    ) {
        abort(0)
    }

    /// Swap an amount of coins for fungible assets. User can specifies the minimum amount they expect to receive.
    public entry fun exact_output_coin_for_asset_entry<FromCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in_max: u64,
        _amount_out: u64,
        _sqrt_price_limit: u128,
        _to_token: Object<Metadata>,
        _recipient: address,
        _deadline: u64
    ) {
        abort(0);
    }

    /// Swap an amount of fungible assets for coins. User can specifies the minimum amount they expect to receive.
    public entry fun exact_output_asset_for_coin_entry<ToCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in_max: u64,
        _amount_out: u64,
        _sqrt_price_limit: u128,
        _from_token: Object<Metadata>,
        _recipient: address,
        _deadline: u64
    ) {
        abort(0);
    }

    /// Swap an amount of coins for another coin. User can specifies the minimum amount they expect to receive.
    public entry fun exact_output_coin_for_coin_entry<FromCoin, ToCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in_max: u64,
        _amount_out: u64,
        _sqrt_price_limit: u128,
        _recipient: address,
        _deadline: u64
    ) {
        abort(0)
    }

    public entry fun swap_batch_coin_entry<T>(
        _user: &signer,
        _lp_path: vector<address>,
        _from_token: Object<Metadata>,
        _to_token: Object<Metadata>,
        _amount_in: u64,
        _amount_out_min: u64,
        _recipient: address
    ) {
        abort(0)
    }

    public entry fun swap_batch(
        _user: &signer,
        _lp_path: vector<address>,
        _from_token: Object<Metadata>,
        _to_token: Object<Metadata>,
        _amount_in: u64,
        _amount_out_min: u64,
        _recipient: address
    ) {
        abort(0);
    }

    public entry fun claim_rewards(
        _user: &signer, _position: Object<position_v3::Info>, _receiver: address
    ) {
        abort(0);
    }

    // TODO: get_amount_by_liquidity_active
    ///////////////////////////////  view  /////////////////////////////////
    #[view]
    public fun get_amount_by_liquidity(
        _position: Object<position_v3::Info>
    ): (u64, u64) {
        (0, 0)
    }

    #[view]
    public fun optimal_liquidity_amounts(
        _tick_lower_u32: u32,
        _tick_upper_u32: u32,
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8,
        _amount_a_desired: u64,
        _amount_b_desired: u64,
        _amount_a_min: u64,
        _amount_b_min: u64
    ): (u128, u64, u64) {
        (0, 0, 0)
    }

    #[view]
    public fun optimal_liquidity_amounts_from_a(
        _tick_lower_u32: u32,
        _tick_upper_u32: u32,
        _tick_current_u32: u32,
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8,
        _amount_a_desired: u64,
        _amount_a_min: u64,
        _amount_b_min: u64
    ): (u128, u64) {
        (0, 0)
    }

    #[view]
    public fun optimal_liquidity_amounts_from_b(
        _tick_lower_u32: u32,
        _tick_upper_u32: u32,
        _tick_current_u32: u32,
        _token_a: Object<Metadata>,
        _token_b: Object<Metadata>,
        _fee_tier: u8,
        _amount_b_desired: u64,
        _amount_a_min: u64,
        _amount_b_min: u64
    ): (u128, u64) {
        (0, 0)
    }

    #[view]
    public fun get_batch_amount_out(
        _lp_path: vector<address>,
        _amount_in: u64,
        _from_token: Object<Metadata>,
        _to_token: Object<Metadata>
    ): u64 {
        0
    }

    #[view]
    public fun get_batch_amount_in(
        _lp_path: vector<address>,
        _amount_out: u64,
        _from_token: Object<Metadata>,
        _to_token: Object<Metadata>
    ): u64 {
        0
    }
}
