module hyperion_interface_addr::partnership {

    use std::string::String;
    use aptos_framework::object::{Object};
    use aptos_framework::fungible_asset::{Self, FungibleAsset, Metadata};
    use hyperion_interface_addr::pool_v3::LiquidityPoolV3;

    const ELP_NOT_EMPTY: u64 = 1400001;
    const EOUT_TOKEN_NOT_MATCHED: u64 = 1400002;
    const EAMOUNT_OUT_TOO_LESS: u64 = 1400003;
    const EAMOUNT_IN_TOO_MUCH: u64 = 1400004;
    const EMETADATA_NOT_MATCHED: u64 = 1400005;
    const EOUT_AMOUNT_TOO_LESS: u64 = 1400006;

    #[event]
    struct PartnerSwapEvent has copy, drop, store {
        pool_id: address,
        partner: String,
        amount_in: u64,
        token_in: Object<Metadata>
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
        _partner: String,
        _deadline: u64
    ) {}

    /// Swap an amount of coins for fungible assets. User can specifies the minimum amount they expect to receive.
    public entry fun exact_input_coin_for_asset_entry<FromCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in: u64,
        _amount_out_min: u64,
        _sqrt_price_limit: u128,
        _to_token: Object<Metadata>,
        _recipient: address,
        _partner: String,
        _deadline: u64
    ) {}

    /// Swap an amount of fungible assets for coins. User can specifies the minimum amount they expect to receive.
    public entry fun exact_input_asset_for_coin_entry<ToCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in: u64,
        _amount_out_min: u64,
        _sqrt_price_limit: u128,
        _from_token: Object<Metadata>,
        _recipient: address,
        _partner: String,
        _deadline: u64
    ) {}

    /// Swap an amount of coins for another coin. User can specifies the minimum amount they expect to receive.
    public entry fun exact_input_coin_for_coin_entry<FromCoin, ToCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in: u64,
        _amount_out_min: u64,
        _sqrt_price_limit: u128,
        _recipient: address,
        _partner: String,
        _deadline: u64
    ) {}

    public entry fun exact_output_swap_entry(
        _user: &signer,
        _fee_tier: u8,
        _amount_in_max: u64,
        _amount_out: u64,
        _sqrt_price_limit: u128,
        _from_token: Object<Metadata>,
        _to_token: Object<Metadata>,
        _recipient: address,
        _partner: String,
        _deadline: u64
    ) {}

    /// Swap an amount of coins for fungible assets. User can specifies the minimum amount they expect to receive.
    public entry fun exact_output_coin_for_asset_entry<FromCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in_max: u64,
        _amount_out: u64,
        _sqrt_price_limit: u128,
        _to_token: Object<Metadata>,
        _recipient: address,
        _partner: String,
        _deadline: u64
    ) {}

    /// Swap an amount of fungible assets for coins. User can specifies the minimum amount they expect to receive.
    public entry fun exact_output_asset_for_coin_entry<ToCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in_max: u64,
        _amount_out: u64,
        _sqrt_price_limit: u128,
        _from_token: Object<Metadata>,
        _recipient: address,
        _partner: String,
        _deadline: u64
    ) {}

    /// Swap an amount of coins for another coin. User can specifies the minimum amount they expect to receive.
    public entry fun exact_output_coin_for_coin_entry<FromCoin, ToCoin>(
        _user: &signer,
        _fee_tier: u8,
        _amount_in_max: u64,
        _amount_out: u64,
        _sqrt_price_limit: u128,
        _recipient: address,
        _partner: String,
        _deadline: u64
    ) {}

    public entry fun swap_batch_coin_entry<T>(
        _user: &signer,
        _lp_path: vector<address>,
        _from_token: Object<Metadata>,
        _to_token: Object<Metadata>,
        _amount_in: u64,
        _amount_out_min: u64,
        _recipient: address,
        _partner: String
    ) {}

    public entry fun swap_batch(
        _user: &signer,
        _lp_path: vector<address>,
        _from_token: Object<Metadata>,
        _to_token: Object<Metadata>,
        _amount_in: u64,
        _amount_out_min: u64,
        _recipient: address,
        _partner: String
    ) {}

    public fun swap(
        _pool: Object<LiquidityPoolV3>,
        _a2b: bool,
        _by_amount_in: bool,
        _amount: u64,
        _fa_in: FungibleAsset,
        _sqrt_price_limit: u128,
        _partner: String
    ): (u64, FungibleAsset, FungibleAsset) {
        let metadata = fungible_asset::metadata_from_asset(&_fa_in);
        (0, _fa_in, fungible_asset::zero(metadata))
    }
}
