module hyperion_interface_addr::swap_math {
    use hyperion_interface_addr::i32::{I32};

    public fun get_amount_by_liquidity(
        _tick_lower: I32,
        _tick_upper: I32,
        _current_tick_index: I32,
        _current_sqrt_price: u128,
        _liquidity: u128,
        _round_up: bool
    ): (u64, u64) {
        (0, 0)
    }

    public fun get_liquidity_by_amount(
        _lower_index: I32,
        _upper_index: I32,
        _current_tick_index: I32,
        _current_sqrt_price: u128,
        _amount: u64,
        _is_fixed_a: bool
    ): (u128, u64, u64) {
        (0, 0, 0)
    }
}
